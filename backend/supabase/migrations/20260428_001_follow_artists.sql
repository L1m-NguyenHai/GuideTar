create table if not exists user_followed_artists (
    user_id uuid not null references users(id) on delete cascade,
    artist_name text not null,
    created_at timestamptz not null default now(),
    primary key (user_id, artist_name)
);

create index if not exists ix_user_followed_artists_artist_name
    on user_followed_artists (artist_name);

alter table user_followed_artists enable row level security;

drop policy if exists p_user_followed_artists_service_role_all on user_followed_artists;
create policy p_user_followed_artists_service_role_all on user_followed_artists
    for all to service_role using (true) with check (true);