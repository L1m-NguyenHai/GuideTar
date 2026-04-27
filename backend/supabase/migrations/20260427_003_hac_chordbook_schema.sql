-- Dynamic schema for HopAmChuan chord-book ingestion.

create table if not exists hac_songs (
    id uuid primary key default gen_random_uuid(),
    source_song_id bigint not null unique,
    source_url text not null unique,
    slug text not null,
    title text not null,
    artists_raw text,
    rhythm_name text,
    key_original text,
    capo smallint check (capo is null or (capo >= 0 and capo <= 24)),
    genre_names text[] not null default '{}',
    view_count integer,
    favorite_count integer,
    crawl_status text not null default 'ok' check (crawl_status in ('ok', 'parse_failed', 'removed')),
    content_hash text,
    crawled_at timestamptz,
    last_success_crawl_at timestamptz,
    last_error text,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists ix_hac_songs_title on hac_songs (title);
create index if not exists ix_hac_songs_crawl_status on hac_songs (crawl_status);
create index if not exists ix_hac_songs_updated_at on hac_songs (updated_at desc);

create table if not exists hac_artists (
    id bigserial primary key,
    name text not null unique,
    source_url text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists hac_song_artists (
    song_id uuid not null references hac_songs(id) on delete cascade,
    artist_id bigint not null references hac_artists(id) on delete cascade,
    is_primary boolean not null default false,
    artist_order smallint not null default 0,
    created_at timestamptz not null default now(),
    primary key (song_id, artist_id)
);

create index if not exists ix_hac_song_artists_artist_id on hac_song_artists (artist_id);

create table if not exists hac_song_versions (
    id uuid primary key default gen_random_uuid(),
    song_id uuid not null references hac_songs(id) on delete cascade,
    version_no integer not null,
    version_label text,
    contributor_name text,
    contributor_url text,
    lyrics_chord_text text not null,
    chord_set text[] not null default '{}',
    key_version text,
    capo smallint check (capo is null or (capo >= 0 and capo <= 24)),
    rhythm_name text,
    source_version_id text,
    source_url text,
    content_hash text,
    crawled_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (song_id, version_no)
);

create index if not exists ix_hac_song_versions_song_id on hac_song_versions (song_id);
create index if not exists ix_hac_song_versions_content_hash on hac_song_versions (content_hash);

create table if not exists hac_song_tags (
    song_id uuid not null references hac_songs(id) on delete cascade,
    tag_type text not null check (tag_type in ('genre', 'rhythm', 'topic', 'other')),
    tag_value text not null,
    created_at timestamptz not null default now(),
    primary key (song_id, tag_type, tag_value)
);

create index if not exists ix_hac_song_tags_tag on hac_song_tags (tag_type, tag_value);

-- RLS baseline
alter table hac_songs enable row level security;
alter table hac_artists enable row level security;
alter table hac_song_artists enable row level security;
alter table hac_song_versions enable row level security;
alter table hac_song_tags enable row level security;

-- Service role policies for backend/crawler operations.
drop policy if exists p_hac_songs_service_role_all on hac_songs;
create policy p_hac_songs_service_role_all on hac_songs
    for all to service_role using (true) with check (true);

drop policy if exists p_hac_artists_service_role_all on hac_artists;
create policy p_hac_artists_service_role_all on hac_artists
    for all to service_role using (true) with check (true);

drop policy if exists p_hac_song_artists_service_role_all on hac_song_artists;
create policy p_hac_song_artists_service_role_all on hac_song_artists
    for all to service_role using (true) with check (true);

drop policy if exists p_hac_song_versions_service_role_all on hac_song_versions;
create policy p_hac_song_versions_service_role_all on hac_song_versions
    for all to service_role using (true) with check (true);

drop policy if exists p_hac_song_tags_service_role_all on hac_song_tags;
create policy p_hac_song_tags_service_role_all on hac_song_tags
    for all to service_role using (true) with check (true);
