from __future__ import annotations

import csv
from pathlib import Path

from .models import CrawledSong


def write_songs_to_csv(songs: list[CrawledSong], output_path: str) -> None:
    path = Path(output_path)
    path.parent.mkdir(parents=True, exist_ok=True)

    with path.open("w", newline="", encoding="utf-8") as file_obj:
        writer = csv.DictWriter(
            file_obj,
            fieldnames=[
                "source_song_id",
                "source_url",
                "slug",
                "title",
                "artists",
                "rhythm_name",
                "lyric_note_text",
                "key_original",
                "genre_names",
                "chord_set",
                "version_count",
                "lyrics",
            ],
        )
        writer.writeheader()

        for song in songs:
            first_lyrics = song.versions[0].lyrics_chord_text if song.versions else ""
            escaped_lyrics = first_lyrics.replace("\r\n", "\n").replace("\n", "\\n")
            writer.writerow(
                {
                    "source_song_id": song.source_song_id,
                    "source_url": song.source_url,
                    "slug": song.slug,
                    "title": song.title,
                    "artists": " | ".join(song.artists),
                    "rhythm_name": song.rhythm_name or "",
                    "lyric_note_text": song.lyric_note_text or "",
                    "key_original": song.key_original or "",
                    "genre_names": " | ".join(song.genre_names),
                    "chord_set": " | ".join(song.chord_set),
                    "version_count": len(song.versions),
                    "lyrics": escaped_lyrics,
                }
            )
