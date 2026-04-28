alter table songs
    add column if not exists source_song_id bigint,
    add column if not exists source_url text,
    add column if not exists key_original text,
    add column if not exists rhythm_name text,
    add column if not exists note text,
    add column if not exists chord_set text,
    add column if not exists lyrics text;

create unique index if not exists ux_songs_source_song_id
    on songs (source_song_id);

create table if not exists artist_profiles (
    id uuid primary key default gen_random_uuid(),
    name text not null unique,
    image_url text,
    image_source text,
    song_count integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists ix_artist_profiles_song_count_name
    on artist_profiles (song_count desc, name asc);
