from __future__ import annotations

import argparse
import asyncio
import logging

from .config import Settings
from .csv_export import write_songs_to_csv
from .db import CrawlerRepository, create_pool
from .ingest import CrawlService


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

    return parser


async def run_command(args: argparse.Namespace) -> int:
    settings = Settings()

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
