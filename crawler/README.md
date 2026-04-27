# GuideTar Crawler

Python crawler project for ingesting HopAmChuan data into GuideTar chord-book tables.

## Setup

```bash
cd crawler
uv sync
copy .env.example .env
```

Fill `DATABASE_URL` (or `SUPABASE_DB_URL`) in `.env`.

## Commands

Crawl listing to CSV only (recommended for data quality check before DB writes):

```bash
uv run crawler crawl-listing-csv https://hopamchuan.com/ --limit 50 --out output/hac_songs.csv
```

Crawl one song:

```bash
uv run crawler crawl-song https://hopamchuan.com/song/9221/noi-nay-co-anh/
```

Crawl from listing page (first N songs found):

```bash
uv run crawler crawl-listing https://hopamchuan.com/ --limit 50
```

## Notes

- Current parser is a practical MVP and may need updates if source HTML changes.
- Crawler uses low-rate access and retry with backoff.
- Data is upserted to `hac_*` tables created by backend migration.
