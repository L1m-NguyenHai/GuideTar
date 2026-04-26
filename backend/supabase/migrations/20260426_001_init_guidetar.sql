create extension if not exists pgcrypto;

create table if not exists users (
    id uuid primary key default gen_random_uuid(),
    email text not null,
    password_hash text not null,
    username text not null,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create unique index if not exists ux_users_email_lower on users (lower(email));
create unique index if not exists ux_users_username on users (username);

create table if not exists user_profiles (
    user_id uuid primary key references users(id) on delete cascade,
    display_name text,
    avatar_url text,
    bio text,
    rank_label text,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists subscription_plans (
    id uuid primary key default gen_random_uuid(),
    code text not null unique,
    name text not null,
    price_monthly numeric(12,2) not null,
    price_yearly numeric(12,2) not null,
    currency text not null default 'VND',
    trial_days integer not null default 0,
    is_active boolean not null default true,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists user_subscriptions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    plan_id uuid not null references subscription_plans(id),
    status text not null check (status in ('active', 'trial', 'canceled', 'expired')),
    started_at timestamptz not null default now(),
    renew_at timestamptz,
    canceled_at timestamptz,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create index if not exists ix_user_subscriptions_user_started_at on user_subscriptions (user_id, started_at desc);

create table if not exists payment_methods (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    type text not null check (type in ('card', 'qr')),
    provider text,
    masked_label text,
    is_default boolean not null default false,
    created_at timestamptz not null default now()
);

create table if not exists payment_transactions (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    subscription_id uuid references user_subscriptions(id) on delete set null,
    payment_code text not null,
    amount numeric(12,2) not null,
    currency text not null,
    status text not null check (status in ('pending', 'paid', 'failed', 'canceled')),
    method_type text not null,
    paid_at timestamptz,
    created_at timestamptz not null default now()
);

create unique index if not exists ux_payment_transactions_payment_code on payment_transactions (payment_code);
create index if not exists ix_payment_transactions_user_created_at on payment_transactions (user_id, created_at desc);

create table if not exists songs (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    artist text,
    duration_seconds integer,
    thumbnail_url text,
    youtube_url text,
    created_at timestamptz not null default now()
);

create table if not exists lessons (
    id uuid primary key default gen_random_uuid(),
    title text not null,
    description text,
    level text,
    thumbnail_url text,
    created_at timestamptz not null default now()
);

create table if not exists user_favorite_songs (
    user_id uuid not null references users(id) on delete cascade,
    song_id uuid not null references songs(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (user_id, song_id)
);

create table if not exists user_favorite_lessons (
    user_id uuid not null references users(id) on delete cascade,
    lesson_id uuid not null references lessons(id) on delete cascade,
    created_at timestamptz not null default now(),
    primary key (user_id, lesson_id)
);

create table if not exists practice_daily_stats (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    stat_date date not null,
    practice_minutes integer not null default 0,
    song_count integer not null default 0,
    lesson_count integer not null default 0,
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now(),
    unique (user_id, stat_date)
);

create table if not exists dechord_analyses (
    id uuid primary key default gen_random_uuid(),
    user_id uuid references users(id) on delete set null,
    source_type text not null check (source_type in ('file', 'youtube')),
    source_name text,
    source_url text,
    bpm double precision,
    time_signature integer,
    chord_count integer not null default 0,
    raw_chord_count integer not null default 0,
    created_at timestamptz not null default now()
);

create index if not exists ix_dechord_analyses_user_created_at on dechord_analyses (user_id, created_at desc);

create table if not exists dechord_analysis_beats (
    id bigserial primary key,
    analysis_id uuid not null references dechord_analyses(id) on delete cascade,
    beat_index integer not null,
    beat_time_seconds double precision,
    chord_label text,
    created_at timestamptz not null default now()
);

create index if not exists ix_dechord_analysis_beats_analysis_beat on dechord_analysis_beats (analysis_id, beat_index);

create table if not exists faq_categories (
    id uuid primary key default gen_random_uuid(),
    code text not null unique,
    name text not null,
    sort_order integer not null default 0,
    created_at timestamptz not null default now()
);

create table if not exists faqs (
    id uuid primary key default gen_random_uuid(),
    category_id uuid not null references faq_categories(id) on delete cascade,
    question text not null,
    answer text not null,
    is_active boolean not null default true,
    sort_order integer not null default 0,
    created_at timestamptz not null default now()
);

create table if not exists support_conversations (
    id uuid primary key default gen_random_uuid(),
    user_id uuid not null references users(id) on delete cascade,
    status text not null check (status in ('open', 'waiting_user', 'closed')),
    created_at timestamptz not null default now(),
    updated_at timestamptz not null default now()
);

create table if not exists support_messages (
    id uuid primary key default gen_random_uuid(),
    conversation_id uuid not null references support_conversations(id) on delete cascade,
    sender_type text not null check (sender_type in ('user', 'agent', 'bot')),
    message_text text not null,
    created_at timestamptz not null default now()
);

create index if not exists ix_support_messages_conversation_created_at
    on support_messages (conversation_id, created_at);

insert into subscription_plans (code, name, price_monthly, price_yearly, currency, trial_days, is_active)
values
    ('SOLO', 'Solo', 99000, 999000, 'VND', 7, true),
    ('MAESTRO', 'Maestro', 199000, 1999000, 'VND', 14, true)
on conflict (code) do update
set name = excluded.name,
    price_monthly = excluded.price_monthly,
    price_yearly = excluded.price_yearly,
    currency = excluded.currency,
    trial_days = excluded.trial_days,
    is_active = excluded.is_active;

insert into faq_categories (code, name, sort_order)
values
    ('ACCOUNT', 'Account', 1),
    ('PAYMENT', 'Payment', 2),
    ('DECHORD', 'AI DeChord', 3)
on conflict (code) do update
set name = excluded.name,
    sort_order = excluded.sort_order;
