from __future__ import annotations

import re
from dataclasses import dataclass
from urllib.parse import urljoin, urlparse

from bs4 import BeautifulSoup

from .models import CrawledSong, CrawledVersion


_SONG_PATH_RE = re.compile(r"/song/(\d+)/([\w\-]+)")
_CHORD_RE = re.compile(r"\[\s*\[?\s*([^\]\[]+?)\s*\]?\s*\]")
_KEY_RE = re.compile(r"\b([A-G](?:#|b)?(?:m|maj|min|dim|aug|sus|add)?\d*(?:/[A-G](?:#|b)?)?)\b")


@dataclass(slots=True)
class SongLink:
    song_id: int
    slug: str
    url: str


class HopAmChuanParser:
    def parse_song_links(self, html: str, base_url: str) -> list[SongLink]:
        soup = BeautifulSoup(html, "lxml")
        links: dict[int, SongLink] = {}

        for anchor in soup.select("a[href*='/song/']"):
            href = anchor.get("href")
            if not href:
                continue
            absolute_url = urljoin(base_url, href)
            path = urlparse(absolute_url).path
            match = _SONG_PATH_RE.search(path)
            if not match:
                continue

            song_id = int(match.group(1))
            slug = match.group(2)
            links[song_id] = SongLink(song_id=song_id, slug=slug, url=absolute_url)

        return list(links.values())

    def parse_song_page(self, html: str, source_url: str, song_id: int, slug: str) -> CrawledSong:
        soup = BeautifulSoup(html, "lxml")

        title = self._extract_title(soup)
        artists = self._extract_artists(soup)
        rhythm_name = self._extract_first_link_text(soup, "a[href*='/rhythm/']")
        genre_names = [item.get_text(strip=True) for item in soup.select("a[href*='/genre/']") if item.get_text(strip=True)]
        lyric_note_text = self._extract_lyric_note_text(soup)
        key_original = self._extract_key_hint(soup)
        capo = None
        lyrics = self._extract_lyrics_block(soup)
        lyrics = self._strip_leading_note_from_lyrics(lyrics, lyric_note_text)
        chord_set = sorted({chord.strip() for chord in _CHORD_RE.findall(lyrics) if chord.strip()})

        version = CrawledVersion(
            version_no=1,
            version_label="Ver 1",
            contributor_name=None,
            contributor_url=None,
            lyrics_chord_text=lyrics,
            chord_set=chord_set,
            key_version=key_original,
            capo=capo,
            rhythm_name=rhythm_name,
            source_url=source_url,
        )

        return CrawledSong(
            source_song_id=song_id,
            source_url=source_url,
            slug=slug,
            title=title,
            artists=artists,
            rhythm_name=rhythm_name,
            lyric_note_text=lyric_note_text,
            key_original=key_original,
            capo=capo,
            genre_names=genre_names,
            chord_set=chord_set,
            versions=[version],
            raw_html=html,
        )

    def _extract_lyric_note_text(self, soup: BeautifulSoup) -> str | None:
        lyric_note = soup.select_one("#song-lyric .song-lyric-note")
        if lyric_note is None:
            return None

        text = lyric_note.get_text(" ", strip=True)
        return text or None

    def _extract_title(self, soup: BeautifulSoup) -> str:
        h1 = soup.select_one("h1")
        if h1 and h1.get_text(strip=True):
            return h1.get_text(strip=True)

        og = soup.select_one("meta[property='og:title']")
        if og and og.get("content"):
            return str(og["content"]).strip()

        title = soup.select_one("title")
        if title and title.get_text(strip=True):
            return title.get_text(strip=True)

        return "unknown"

    def _extract_artists(self, soup: BeautifulSoup) -> list[str]:
        artists = [item.get_text(strip=True) for item in soup.select("a[href*='/artist/']") if item.get_text(strip=True)]
        deduped: list[str] = []
        for artist in artists:
            if artist not in deduped:
                deduped.append(artist)
        return deduped

    def _extract_key_hint(self, soup: BeautifulSoup) -> str | None:
        lyric_note = soup.select_one("#song-lyric .song-lyric-note")
        if lyric_note is not None:
            key_node = lyric_note.select_one(".hopamchuan_chord")
            if key_node is not None:
                key_text = key_node.get_text(strip=True)
                if key_text:
                    return key_text

            note_text = lyric_note.get_text(" ", strip=True)
            note_match = re.search(r"Tone\s*([A-G][#b]?m?)", note_text, flags=re.IGNORECASE)
            if note_match:
                return note_match.group(1)

        text = soup.get_text(" ", strip=True)
        match = re.search(r"Giọng\s+([A-G][#b]?m?)", text, flags=re.IGNORECASE)
        if match:
            return match.group(1)

        # Last-resort fallback: infer first valid chord token from lyric block.
        lyric_text = self._extract_lyrics_block(soup)
        for token in _KEY_RE.findall(lyric_text):
            clean = token.strip()
            if clean:
                return clean

        return None

    def _extract_lyrics_block(self, soup: BeautifulSoup) -> str:
        song_lyric = soup.select_one("#song-lyric")
        if song_lyric is not None:
            lyric_lines = self._extract_song_lyric_lines(song_lyric)
            if lyric_lines:
                return "\n".join(lyric_lines)

        candidates = [
            soup.select_one("#song-main-content"),
            soup.select_one("#view-song"),
            soup.select_one(".song-content"),
            soup.select_one(".tab-content"),
            soup.select_one(".song-detail-page"),
        ]

        for container in candidates:
            if container is None:
                continue
            text = container.get_text("\n", strip=True)
            if text:
                return text

        return soup.get_text("\n", strip=True)

    def _extract_song_lyric_lines(self, song_lyric: BeautifulSoup) -> list[str]:
        lines: list[str] = []
        for node in song_lyric.select(".chord_lyric_line"):
            text = " ".join(node.stripped_strings)
            text = re.sub(r"\s+", " ", text).strip()
            if text:
                lines.append(text)
        return lines

    def _strip_leading_note_from_lyrics(self, lyrics: str, lyric_note_text: str | None) -> str:
        if not lyrics or not lyric_note_text:
            return lyrics

        def normalize(value: str) -> str:
            return re.sub(r"\s+", " ", value).strip().lower()

        note_norm = normalize(lyric_note_text)
        lines = lyrics.splitlines()

        while lines:
            first_line = lines[0].strip()
            if not first_line:
                lines.pop(0)
                continue

            first_line_norm = normalize(first_line)
            if first_line_norm == note_norm:
                lines.pop(0)
                continue

            if first_line_norm.startswith(note_norm):
                # Some songs put note and first lyric marker (e.g. Intro:) on one line.
                trimmed = first_line[len(lyric_note_text) :].strip()
                lines[0] = trimmed
                if not lines[0]:
                    lines.pop(0)
                continue

            if note_norm.startswith(first_line_norm) and first_line_norm.startswith(("tone ", "capo ")):
                lines.pop(0)
                continue

            break

        return "\n".join(lines)

    def _extract_first_link_text(self, soup: BeautifulSoup, selector: str) -> str | None:
        node = soup.select_one(selector)
        if not node:
            return None
        value = node.get_text(strip=True)
        return value or None
