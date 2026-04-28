from __future__ import annotations

import csv
from pathlib import Path

import asyncpg

from .config import Settings
from .db import create_pool


def _split_artists(raw: str) -> list[str]:
    if not raw:
        return []
    return [item.strip() for item in raw.split("|") if item.strip()]


def _load_artist_images(artists_csv_path: str) -> dict[str, tuple[str, str]]:
    artists_path = Path(artists_csv_path)
    if not artists_path.exists():
        raise FileNotFoundError(f"Artists CSV not found: {artists_csv_path}")

    with artists_path.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))

    lookup: dict[str, tuple[str, str]] = {}
    for row in rows:
        artist_name = (row.get("artist_name") or "").strip()
        image_url = (row.get("image_url") or "").strip()
        image_source = (row.get("image_source") or "").strip()
        if not artist_name:
            continue
        lookup[artist_name] = (image_url, image_source)

    return lookup


async def sync_public_catalog_from_csv(songs_csv_path: str, artists_csv_path: str) -> dict[str, int]:
    settings = Settings()
    if not settings.database_url:
        raise RuntimeError("Missing DATABASE_URL or SUPABASE_DB_URL")

    songs_path = Path(songs_csv_path)
    if not songs_path.exists():
        raise FileNotFoundError(f"Songs CSV not found: {songs_csv_path}")

    with songs_path.open("r", encoding="utf-8", newline="") as f:
        song_rows = list(csv.DictReader(f))

    artist_image_lookup = _load_artist_images(artists_csv_path)

    pool = await create_pool(settings.database_url)
    upserted_songs = 0
    upserted_artists = 0

    try:
        async with pool.acquire() as conn:
            async with conn.transaction():
                await _ensure_catalog_schema(conn)

                for artist_name, image_data in artist_image_lookup.items():
                    image_url, image_source = image_data
                    song_count = sum(
                        1
                        for row in song_rows
                        if artist_name in _split_artists((row.get("artists") or "").strip())
                    )
                    await conn.execute(
                        """
                        insert into artist_profiles (name, image_url, image_source, song_count, updated_at)
                        values ($1, nullif($2, ''), nullif($3, ''), $4, now())
                        on conflict (name)
                        do update set
                            image_url = excluded.image_url,
                            image_source = excluded.image_source,
                            song_count = excluded.song_count,
                            updated_at = now()
                        """,
                        artist_name,
                        image_url,
                        image_source,
                        song_count,
                    )
                    upserted_artists += 1

                for row in song_rows:
                    source_song_id_raw = (row.get("source_song_id") or "").strip()
                    if not source_song_id_raw.isdigit():
                        continue

                    source_song_id = int(source_song_id_raw)
                    source_url = (row.get("source_url") or "").strip()
                    title = (row.get("title") or "").strip()
                    if not title:
                        continue

                    artists = _split_artists((row.get("artists") or "").strip())
                    primary_artist = artists[0] if artists else ""
                    artist_display = ", ".join(artists) if artists else ""

                    image_url = (row.get("thumbnail_url") or "").strip()
                    if not image_url and primary_artist in artist_image_lookup:
                        image_url = artist_image_lookup[primary_artist][0]

                    youtube_url = (row.get("youtube_url") or "").strip()
                    key_original = (row.get("key_original") or "").strip()
                    rhythm_name = (row.get("rhythm_name") or "").strip()
                    note = (row.get("lyric_note_text") or row.get("note") or "").strip()
                    chord_set = (row.get("chord_set") or "").strip()
                    lyrics = (row.get("lyrics") or "").strip()

                    await conn.execute(
                        """
                        insert into songs (
                            source_song_id,
                            source_url,
                            title,
                            artist,
                            thumbnail_url,
                            youtube_url,
                            key_original,
                            rhythm_name,
                            note,
                            chord_set,
                            lyrics,
                            duration_seconds,
                            created_at
                        ) values (
                            $1,
                            nullif($2, ''),
                            $3,
                            nullif($4, ''),
                            nullif($5, ''),
                            nullif($6, ''),
                            nullif($7, ''),
                            nullif($8, ''),
                            nullif($9, ''),
                            nullif($10, ''),
                            nullif($11, ''),
                            null,
                            now()
                        )
                        on conflict (source_song_id)
                        do update set
                            source_url = excluded.source_url,
                            title = excluded.title,
                            artist = excluded.artist,
                            thumbnail_url = excluded.thumbnail_url,
                            youtube_url = excluded.youtube_url,
                            key_original = excluded.key_original,
                            rhythm_name = excluded.rhythm_name,
                            note = excluded.note,
                            chord_set = excluded.chord_set,
                            lyrics = excluded.lyrics
                        """,
                        source_song_id,
                        source_url,
                        title,
                        artist_display,
                        image_url,
                        youtube_url,
                        key_original,
                        rhythm_name,
                        note,
                        chord_set,
                        lyrics,
                    )
                    upserted_songs += 1

        return {"songs": upserted_songs, "artists": upserted_artists}
    finally:
        await pool.close()


async def _ensure_catalog_schema(conn: asyncpg.Connection) -> None:
    await conn.execute(
        """
        alter table songs
            add column if not exists source_song_id bigint,
            add column if not exists source_url text,
            add column if not exists key_original text,
            add column if not exists rhythm_name text,
            add column if not exists note text,
            add column if not exists chord_set text,
            add column if not exists lyrics text
        """
    )
    await conn.execute(
        """
        create unique index if not exists ux_songs_source_song_id
            on songs (source_song_id)
        """
    )
    await conn.execute(
        """
        create table if not exists artist_profiles (
            id uuid primary key default gen_random_uuid(),
            name text not null unique,
            image_url text,
            image_source text,
            song_count integer not null default 0,
            created_at timestamptz not null default now(),
            updated_at timestamptz not null default now()
        )
        """
    )
    await conn.execute(
        """
        create index if not exists ix_artist_profiles_song_count_name
            on artist_profiles (song_count desc, name asc)
        """
    )
