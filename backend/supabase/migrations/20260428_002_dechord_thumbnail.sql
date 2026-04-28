-- Add thumbnail_url column to dechord_analyses for YouTube video thumbnails
alter table dechord_analyses add column if not exists thumbnail_url text;

-- Create index for faster queries on source_type
create index if not exists ix_dechord_analyses_source_type on dechord_analyses (source_type);
