from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime


@dataclass(slots=True)
class CrawledVersion:
    version_no: int
    version_label: str | None
    contributor_name: str | None
    contributor_url: str | None
    lyrics_chord_text: str
    chord_set: list[str] = field(default_factory=list)
    key_version: str | None = None
    capo: int | None = None
    rhythm_name: str | None = None
    source_version_id: str | None = None
    source_url: str | None = None


@dataclass(slots=True)
class CrawledSong:
    source_song_id: int
    source_url: str
    slug: str
    title: str
    artists: list[str] = field(default_factory=list)
    rhythm_name: str | None = None
    lyric_note_text: str | None = None
    key_original: str | None = None
    capo: int | None = None
    genre_names: list[str] = field(default_factory=list)
    view_count: int | None = None
    favorite_count: int | None = None
    published_at: datetime | None = None
    chord_set: list[str] = field(default_factory=list)
    versions: list[CrawledVersion] = field(default_factory=list)
    raw_html: str = ""
