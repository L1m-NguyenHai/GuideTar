from __future__ import annotations

import argparse
import asyncio
import logging

from .artist_csv import export_artists_csv_from_songs
from .catalog_sync import sync_public_catalog_from_csv
from .config import Settings
from .csv_export import write_songs_to_csv
from .db import CrawlerRepository, create_pool
from .ingest import CrawlService
from .youtube_enrich import enrich_csv_with_youtube


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(description="GuideTar HopAmChuan crawler")
    subparsers = parser.add_subparsers(dest="command", required=True)

    crawl_song = subparsers.add_parser("crawl-song", help="Crawl a single song URL")
    crawl_song.add_argument("url", help="HopAmChuan song URL")

    crawl_listing = subparsers.add_parser("crawl-listing", help="Crawl songs from a listing URL")
    crawl_listing.add_argument("url", help="Listing URL containing /song links")
    crawl_listing.add_argument("--limit", type=int, default=100, help="Maximum songs to crawl from listing")

    crawl_listing_csv = subparsers.add_parser(
        "crawl-listing-csv",
        help="Crawl songs from a listing URL and save to CSV (no DB write)",
    )
    crawl_listing_csv.add_argument("url", help="Listing URL containing /song links")
    crawl_listing_csv.add_argument("--limit", type=int, default=100, help="Maximum songs to crawl from listing")
    crawl_listing_csv.add_argument("--out", default="output/hac_songs.csv", help="Output CSV path")

    enrich_csv = subparsers.add_parser(
        "enrich-youtube-csv",
        help="Search YouTube by title and write youtube_url + thumbnail_url columns",
    )
    enrich_csv.add_argument("--csv", required=True, help="Input CSV path")
    enrich_csv.add_argument(
        "--delay",
        type=float,
        default=0.35,
        help="Delay between lookups in seconds",
    )
    enrich_csv.add_argument(
        "--search-results",
        type=int,
        default=5,
        help="Number of YouTube candidates to score per song",
    )

    artist_csv = subparsers.add_parser(
        "export-artists-csv",
        help="Split artists from songs CSV and export artist image CSV",
    )
    artist_csv.add_argument("--songs-csv", required=True, help="Input songs CSV path")
    artist_csv.add_argument("--out", default="output/hac_tacgia.csv", help="Output artist CSV path")
    artist_csv.add_argument(
        "--with-youtube-fallback",
        action="store_true",
        help="Enable slower yt-dlp fallback when Deezer/Wikipedia have no image",
    )

    sync_catalog = subparsers.add_parser(
        "sync-public-catalog",
        help="Sync songs/artists CSV data into backend public catalog tables",
    )
    sync_catalog.add_argument("--songs-csv", default="output/hac_songs.csv", help="Input songs CSV path")
    sync_catalog.add_argument("--artists-csv", default="output/hac_tacgia.csv", help="Input artists CSV path")

    return parser


async def run_command(args: argparse.Namespace) -> int:
    settings = Settings()

    if args.command == "enrich-youtube-csv":
        updated = enrich_csv_with_youtube(
            args.csv,
            delay_seconds=args.delay,
            search_results=max(1, args.search_results),
        )
        logging.info("YouTube enrichment completed. csv=%s updated=%s", args.csv, updated)
        return 0

    if args.command == "export-artists-csv":
        total = export_artists_csv_from_songs(
            args.songs_csv,
            args.out,
            use_youtube_fallback=args.with_youtube_fallback,
        )
        logging.info("Artist CSV generated at %s. rows=%s", args.out, total)
        return 0

    if args.command == "sync-public-catalog":
        summary = await sync_public_catalog_from_csv(args.songs_csv, args.artists_csv)
        logging.info(
            "Catalog sync done. songs=%s artists=%s",
            summary.get("songs", 0),
            summary.get("artists", 0),
        )
        return 0

    if args.command == "crawl-listing-csv":
        service = CrawlService(settings)
        songs, failed = await service.crawl_listing_songs(args.url, limit=args.limit)
        write_songs_to_csv(songs, args.out)
        logging.info("CSV generated at %s. rows=%s failed=%s", args.out, len(songs), failed)
        return 0 if songs else 2

    if not settings.database_url:
        raise RuntimeError("Missing DATABASE_URL or SUPABASE_DB_URL for DB write commands")

    pool = await create_pool(settings.database_url)
    try:
        repo = CrawlerRepository(pool)
        service = CrawlService(settings, repo)

        if args.command == "crawl-song":
            ok = await service.crawl_song(args.url)
            return 0 if ok else 1

        if args.command == "crawl-listing":
            success, failed = await service.crawl_listing(args.url, limit=args.limit)
            logging.info("Crawl completed. success=%s failed=%s", success, failed)
            return 0 if failed == 0 else 2

        raise RuntimeError(f"Unsupported command: {args.command}")
    finally:
        await pool.close()


def main() -> None:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(name)s - %(message)s")
    parser = build_parser()
    args = parser.parse_args()
    raise SystemExit(asyncio.run(run_command(args)))
