from __future__ import annotations

import hashlib
from typing import Any

import asyncpg

from .models import CrawledSong, CrawledVersion


class CrawlerRepository:
    def __init__(self, pool: asyncpg.Pool) -> None:
        self._pool = pool

    @staticmethod
    def _content_hash(value: str) -> str:
        return hashlib.sha256(value.encode("utf-8")).hexdigest()

    async def upsert_song(self, song: CrawledSong) -> str:
        artists = ", ".join(song.artists) if song.artists else None
        content_hash = self._content_hash(song.raw_html or song.title)

        async with self._pool.acquire() as conn:
            async with conn.transaction():
                song_id = await conn.fetchval(
                    """
                    insert into hac_songs (
                        source_song_id,
                        source_url,
                        slug,
                        title,
                        artists_raw,
                        rhythm_name,
                        key_original,
                        capo,
                        genre_names,
                        view_count,
                        favorite_count,
                        crawl_status,
                        content_hash,
                        crawled_at,
                        last_success_crawl_at,
                        last_error,
                        updated_at
                    ) values (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9::text[], $10, $11,
                        'ok', $12, now(), now(), null, now()
                    )
                    on conflict (source_song_id)
                    do update set
                        source_url = excluded.source_url,
                        slug = excluded.slug,
                        title = excluded.title,
                        artists_raw = excluded.artists_raw,
                        rhythm_name = excluded.rhythm_name,
                        key_original = excluded.key_original,
                        capo = excluded.capo,
                        genre_names = excluded.genre_names,
                        view_count = excluded.view_count,
                        favorite_count = excluded.favorite_count,
                        crawl_status = 'ok',
                        content_hash = excluded.content_hash,
                        crawled_at = now(),
                        last_success_crawl_at = now(),
                        last_error = null,
                        updated_at = now()
                    returning id
                    """,
                    song.source_song_id,
                    song.source_url,
                    song.slug,
                    song.title,
                    artists,
                    song.rhythm_name,
                    song.key_original,
                    song.capo,
                    song.genre_names,
                    song.view_count,
                    song.favorite_count,
                    content_hash,
                )

                await conn.execute(
                    "delete from hac_song_artists where song_id = $1",
                    song_id,
                )

                for index, artist_name in enumerate(song.artists):
                    artist_id = await conn.fetchval(
                        """
                        insert into hac_artists (name)
                        values ($1)
                        on conflict (name)
                        do update set updated_at = now()
                        returning id
                        """,
                        artist_name,
                    )
                    await conn.execute(
                        """
                        insert into hac_song_artists (song_id, artist_id, is_primary, artist_order)
                        values ($1, $2, $3, $4)
                        on conflict (song_id, artist_id)
                        do update set
                            is_primary = excluded.is_primary,
                            artist_order = excluded.artist_order
                        """,
                        song_id,
                        artist_id,
                        index == 0,
                        index,
                    )

                if song.versions:
                    await conn.execute("delete from hac_song_versions where song_id = $1", song_id)
                    for version in song.versions:
                        await self._insert_version(conn, song_id, version)

                if song.genre_names:
                    await conn.execute("delete from hac_song_tags where song_id = $1", song_id)
                    for tag in song.genre_names:
                        await conn.execute(
                            """
                            insert into hac_song_tags (song_id, tag_type, tag_value)
                            values ($1, 'genre', $2)
                            on conflict (song_id, tag_type, tag_value) do nothing
                            """,
                            song_id,
                            tag,
                        )

                return str(song_id)

    async def mark_failed(self, source_song_id: int, source_url: str, error_message: str) -> None:
        async with self._pool.acquire() as conn:
            await conn.execute(
                """
                insert into hac_songs (source_song_id, source_url, slug, title, crawl_status, last_error)
                values ($1, $2, '', 'unknown', 'parse_failed', left($3, 1000))
                on conflict (source_song_id)
                do update set
                    crawl_status = 'parse_failed',
                    last_error = left(excluded.last_error, 1000),
                    crawled_at = now(),
                    updated_at = now()
                """,
                source_song_id,
                source_url,
                error_message,
            )

    async def _insert_version(self, conn: asyncpg.Connection, song_id: Any, version: CrawledVersion) -> None:
        lyrics_hash = self._content_hash(version.lyrics_chord_text)
        await conn.execute(
            """
            insert into hac_song_versions (
                song_id,
                version_no,
                version_label,
                contributor_name,
                contributor_url,
                lyrics_chord_text,
                chord_set,
                key_version,
                capo,
                rhythm_name,
                source_version_id,
                source_url,
                content_hash,
                crawled_at
            ) values (
                $1, $2, $3, $4, $5, $6, $7::text[], $8, $9, $10, $11, $12, $13, now()
            )
            on conflict (song_id, version_no)
            do update set
                version_label = excluded.version_label,
                contributor_name = excluded.contributor_name,
                contributor_url = excluded.contributor_url,
                lyrics_chord_text = excluded.lyrics_chord_text,
                chord_set = excluded.chord_set,
                key_version = excluded.key_version,
                capo = excluded.capo,
                rhythm_name = excluded.rhythm_name,
                source_version_id = excluded.source_version_id,
                source_url = excluded.source_url,
                content_hash = excluded.content_hash,
                crawled_at = now(),
                updated_at = now()
            """,
            song_id,
            version.version_no,
            version.version_label,
            version.contributor_name,
            version.contributor_url,
            version.lyrics_chord_text,
            version.chord_set,
            version.key_version,
            version.capo,
            version.rhythm_name,
            version.source_version_id,
            version.source_url,
            lyrics_hash,
        )


async def create_pool(database_url: str) -> asyncpg.Pool:
    return await asyncpg.create_pool(
        dsn=database_url,
        min_size=1,
        max_size=8,
        statement_cache_size=0,
    )
