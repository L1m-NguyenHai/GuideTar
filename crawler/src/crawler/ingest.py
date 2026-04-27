from __future__ import annotations

import asyncio
import logging
import random
from typing import Optional

import httpx
from tenacity import retry, stop_after_attempt, wait_exponential

from .config import Settings
from .db import CrawlerRepository
from .parser import HopAmChuanParser, SongLink

logger = logging.getLogger(__name__)


class CrawlService:
    def __init__(self, settings: Settings, repo: Optional[CrawlerRepository] = None) -> None:
        self._settings = settings
        self._repo = repo
        self._parser = HopAmChuanParser()

    async def crawl_listing(self, listing_url: str, limit: int = 100) -> tuple[int, int]:
        html = await self._fetch_html(listing_url)
        links = self._parser.parse_song_links(html, base_url=listing_url)
        selected_links = links[:limit]

        success_count = 0
        fail_count = 0

        for link in selected_links:
            await self._polite_delay()
            ok = await self.crawl_song(link)
            if ok:
                success_count += 1
            else:
                fail_count += 1

        return success_count, fail_count

    async def crawl_listing_songs(self, listing_url: str, limit: int = 100) -> tuple[list, int]:
        html = await self._fetch_html(listing_url)
        links = self._parser.parse_song_links(html, base_url=listing_url)
        selected_links = links[:limit]

        songs = []
        fail_count = 0
        for link in selected_links:
            await self._polite_delay()
            song = await self.fetch_song(link)
            if song is None:
                fail_count += 1
                continue
            songs.append(song)

        return songs, fail_count

    async def fetch_song(self, link_or_url: SongLink | str):
        if isinstance(link_or_url, SongLink):
            link = link_or_url
        else:
            parsed = self._parser.parse_song_links(f'<a href="{link_or_url}">song</a>', link_or_url)
            if not parsed:
                logger.error("Invalid song url: %s", link_or_url)
                return None
            link = parsed[0]

        try:
            html = await self._fetch_html(link.url)
            song = self._parser.parse_song_page(html, source_url=link.url, song_id=link.song_id, slug=link.slug)
            return song
        except Exception as exc:  # noqa: BLE001
            logger.exception("Failed to crawl song %s", link.url)
            if self._repo is not None:
                await self._repo.mark_failed(link.song_id, link.url, str(exc))
            return None

    async def crawl_song(self, link_or_url: SongLink | str) -> bool:
        song = await self.fetch_song(link_or_url)
        if song is None:
            return False

        if self._repo is None:
            logger.info("Fetched song %s - %s", song.source_song_id, song.title)
            return True

        await self._repo.upsert_song(song)
        logger.info("Upserted song %s - %s", song.source_song_id, song.title)
        return True

    @retry(wait=wait_exponential(multiplier=0.8, min=1, max=8), stop=stop_after_attempt(3), reraise=True)
    async def _fetch_html(self, url: str) -> str:
        timeout = httpx.Timeout(self._settings.request_timeout_sec)
        headers = {
            "User-Agent": self._settings.user_agent,
            "Accept-Language": "vi-VN,vi;q=0.9,en;q=0.7",
        }
        async with httpx.AsyncClient(timeout=timeout, follow_redirects=True, headers=headers) as client:
            response = await client.get(url)
            response.raise_for_status()
            return response.text

    async def _polite_delay(self) -> None:
        delay_sec = random.uniform(self._settings.crawl_delay_min_sec, self._settings.crawl_delay_max_sec)
        await asyncio.sleep(delay_sec)
