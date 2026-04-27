from __future__ import annotations

import csv
import logging
import re
import unicodedata
from collections import defaultdict
from pathlib import Path
from typing import Any

import httpx
from yt_dlp import YoutubeDL


logger = logging.getLogger(__name__)

DEFAULT_HTTP_HEADERS = {
    "User-Agent": "GuideTarCrawler/1.0 (+https://github.com/L1m-NguyenHai/GuideTar)",
    "Accept": "application/json, text/plain, */*",
}


def _split_artists(raw: str) -> list[str]:
    if not raw:
        return []
    return [item.strip() for item in raw.split("|") if item.strip()]


def _normalize_text(text: str) -> str:
    text = unicodedata.normalize("NFKD", text)
    text = "".join(ch for ch in text if not unicodedata.combining(ch))
    return text.lower()


def _tokenize(text: str) -> list[str]:
    normalized = _normalize_text(text)
    return [t for t in re.findall(r"[a-z0-9]+", normalized) if len(t) > 1]


def _lookup_deezer_image(client: httpx.Client, artist_name: str) -> str:
    response = client.get(
        "https://api.deezer.com/search/artist",
        params={"q": artist_name},
    )
    response.raise_for_status()
    payload = response.json()
    data = payload.get("data") or []
    if not data:
        return ""

    first = data[0] or {}
    return (
        first.get("picture_xl")
        or first.get("picture_big")
        or first.get("picture_medium")
        or first.get("picture")
        or ""
    )


def _lookup_wikipedia_image(client: httpx.Client, artist_name: str) -> str:
    search_resp = client.get(
        "https://en.wikipedia.org/w/api.php",
        params={
            "action": "query",
            "list": "search",
            "srsearch": f"{artist_name} musician",
            "srlimit": "1",
            "format": "json",
        },
    )
    search_resp.raise_for_status()
    search_data = search_resp.json().get("query", {}).get("search", [])
    if not search_data:
        return ""

    page_id = search_data[0].get("pageid")
    if not page_id:
        return ""

    image_resp = client.get(
        "https://en.wikipedia.org/w/api.php",
        params={
            "action": "query",
            "prop": "pageimages",
            "pageids": str(page_id),
            "pithumbsize": "800",
            "format": "json",
        },
    )
    image_resp.raise_for_status()
    pages = image_resp.json().get("query", {}).get("pages", {})
    page = pages.get(str(page_id), {})
    return page.get("thumbnail", {}).get("source", "")


def _find_channel_avatar_from_info(channel_info: dict[str, Any]) -> str:
    direct = (channel_info.get("thumbnail") or "").strip()
    if direct:
        return direct

    thumbs = channel_info.get("thumbnails") or []
    if not thumbs:
        return ""

    sorted_thumbs = sorted(
        [t for t in thumbs if t and t.get("url")],
        key=lambda t: int((t.get("height") or 0)),
        reverse=True,
    )
    return (sorted_thumbs[0] or {}).get("url", "") if sorted_thumbs else ""


def _score_video_for_artist(entry: dict[str, Any], artist_name: str) -> int:
    artist_tokens = _tokenize(artist_name)
    title = _normalize_text(entry.get("title") or "")
    channel = _normalize_text(entry.get("channel") or "")
    candidate = f"{title} {channel}"

    score = sum(4 for t in artist_tokens if t in candidate)

    for marker in ["official", "artist", "topic"]:
        if marker in candidate:
            score += 2

    for marker in ["karaoke", "cover", "remix", "reaction", "live"]:
        if marker in candidate:
            score -= 3

    return score


def _lookup_youtube_channel_image(artist_name: str) -> str:
    ydl_opts: dict[str, Any] = {
        "quiet": True,
        "no_warnings": True,
        "skip_download": True,
        "noplaylist": True,
        "ignoreerrors": True,
        "socket_timeout": 10,
        "retries": 1,
        "extractor_retries": 1,
    }
    query = f"{artist_name} official artist"

    with YoutubeDL(ydl_opts) as ydl:  # type: ignore[arg-type]
        result = ydl.extract_info(f"ytsearch5:{query}", download=False) or {}

    entries = [e for e in (result.get("entries") or []) if e]
    if not entries:
        return ""

    best_entry = max(entries, key=lambda e: _score_video_for_artist(e, artist_name))
    channel_url = (best_entry.get("channel_url") or best_entry.get("uploader_url") or "").strip()
    if not channel_url:
        return ""

    try:
        with YoutubeDL(ydl_opts) as ydl:  # type: ignore[arg-type]
            channel_info = ydl.extract_info(channel_url, download=False) or {}
    except Exception:
        return ""

    return _find_channel_avatar_from_info(channel_info)


def _lookup_artist_image(
    client: httpx.Client,
    artist_name: str,
    *,
    use_youtube_fallback: bool,
) -> tuple[str, str]:
    try:
        deezer_url = _lookup_deezer_image(client, artist_name)
        if deezer_url:
            return deezer_url, "deezer"
    except Exception:
        pass

    try:
        wiki_url = _lookup_wikipedia_image(client, artist_name)
        if wiki_url:
            return wiki_url, "wikipedia"
    except Exception:
        pass

    if use_youtube_fallback:
        try:
            youtube_avatar = _lookup_youtube_channel_image(artist_name)
            if youtube_avatar:
                return youtube_avatar, "youtube"
        except Exception:
            pass

    return "", ""


def export_artists_csv_from_songs(
    songs_csv_path: str,
    out_csv_path: str,
    *,
    use_youtube_fallback: bool = False,
) -> int:
    songs_path = Path(songs_csv_path)
    if not songs_path.exists():
        raise FileNotFoundError(f"Songs CSV not found: {songs_csv_path}")

    with songs_path.open("r", encoding="utf-8", newline="") as f:
        rows = list(csv.DictReader(f))

    artist_to_count: dict[str, int] = defaultdict(int)
    artist_to_samples: dict[str, list[str]] = defaultdict(list)

    for row in rows:
        title = (row.get("title") or "").strip()
        for artist in _split_artists((row.get("artists") or "").strip()):
            artist_to_count[artist] += 1
            if title and title not in artist_to_samples[artist] and len(artist_to_samples[artist]) < 3:
                artist_to_samples[artist].append(title)

    out_rows: list[dict[str, str]] = []
    with httpx.Client(timeout=15.0, follow_redirects=True, headers=DEFAULT_HTTP_HEADERS) as client:
        total_artists = len(artist_to_count)
        for index, artist_name in enumerate(sorted(artist_to_count.keys()), start=1):
            image_url, image_source = _lookup_artist_image(
                client,
                artist_name,
                use_youtube_fallback=use_youtube_fallback,
            )
            out_rows.append(
                {
                    "artist_name": artist_name,
                    "song_count": str(artist_to_count[artist_name]),
                    "sample_titles": " | ".join(artist_to_samples[artist_name]),
                    "image_url": image_url,
                    "image_source": image_source,
                }
            )
            if index % 20 == 0 or index == total_artists:
                logger.info("Artist image lookup progress: %s/%s", index, total_artists)

    out_path = Path(out_csv_path)
    out_path.parent.mkdir(parents=True, exist_ok=True)
    fieldnames = ["artist_name", "song_count", "sample_titles", "image_url", "image_source"]

    with out_path.open("w", encoding="utf-8", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(out_rows)

    return len(out_rows)
