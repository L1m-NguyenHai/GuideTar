-- Performance: add indexes for foreign keys flagged by Supabase advisors.
create index if not exists ix_faqs_category_id on faqs (category_id);
create index if not exists ix_payment_methods_user_id on payment_methods (user_id);
create index if not exists ix_payment_transactions_subscription_id on payment_transactions (subscription_id);
create index if not exists ix_support_conversations_user_id on support_conversations (user_id);
create index if not exists ix_user_favorite_lessons_lesson_id on user_favorite_lessons (lesson_id);
create index if not exists ix_user_favorite_songs_song_id on user_favorite_songs (song_id);
create index if not exists ix_user_subscriptions_plan_id on user_subscriptions (plan_id);

-- Security baseline: enable RLS on all public tables.
alter table users enable row level security;
alter table user_profiles enable row level security;
alter table subscription_plans enable row level security;
alter table user_subscriptions enable row level security;
alter table payment_methods enable row level security;
alter table payment_transactions enable row level security;
alter table songs enable row level security;
alter table lessons enable row level security;
alter table user_favorite_songs enable row level security;
alter table user_favorite_lessons enable row level security;
alter table practice_daily_stats enable row level security;
alter table dechord_analyses enable row level security;
alter table dechord_analysis_beats enable row level security;
alter table faq_categories enable row level security;
alter table faqs enable row level security;
alter table support_conversations enable row level security;
alter table support_messages enable row level security;

-- Keep backend service operations working through Supabase service role.
drop policy if exists p_users_service_role_all on users;
create policy p_users_service_role_all on users
    for all to service_role using (true) with check (true);

drop policy if exists p_user_profiles_service_role_all on user_profiles;
create policy p_user_profiles_service_role_all on user_profiles
    for all to service_role using (true) with check (true);

drop policy if exists p_subscription_plans_service_role_all on subscription_plans;
create policy p_subscription_plans_service_role_all on subscription_plans
    for all to service_role using (true) with check (true);

drop policy if exists p_user_subscriptions_service_role_all on user_subscriptions;
create policy p_user_subscriptions_service_role_all on user_subscriptions
    for all to service_role using (true) with check (true);

drop policy if exists p_payment_methods_service_role_all on payment_methods;
create policy p_payment_methods_service_role_all on payment_methods
    for all to service_role using (true) with check (true);

drop policy if exists p_payment_transactions_service_role_all on payment_transactions;
create policy p_payment_transactions_service_role_all on payment_transactions
    for all to service_role using (true) with check (true);

drop policy if exists p_songs_service_role_all on songs;
create policy p_songs_service_role_all on songs
    for all to service_role using (true) with check (true);

drop policy if exists p_lessons_service_role_all on lessons;
create policy p_lessons_service_role_all on lessons
    for all to service_role using (true) with check (true);

drop policy if exists p_user_favorite_songs_service_role_all on user_favorite_songs;
create policy p_user_favorite_songs_service_role_all on user_favorite_songs
    for all to service_role using (true) with check (true);

drop policy if exists p_user_favorite_lessons_service_role_all on user_favorite_lessons;
create policy p_user_favorite_lessons_service_role_all on user_favorite_lessons
    for all to service_role using (true) with check (true);

drop policy if exists p_practice_daily_stats_service_role_all on practice_daily_stats;
create policy p_practice_daily_stats_service_role_all on practice_daily_stats
    for all to service_role using (true) with check (true);

drop policy if exists p_dechord_analyses_service_role_all on dechord_analyses;
create policy p_dechord_analyses_service_role_all on dechord_analyses
    for all to service_role using (true) with check (true);

drop policy if exists p_dechord_analysis_beats_service_role_all on dechord_analysis_beats;
create policy p_dechord_analysis_beats_service_role_all on dechord_analysis_beats
    for all to service_role using (true) with check (true);

drop policy if exists p_faq_categories_service_role_all on faq_categories;
create policy p_faq_categories_service_role_all on faq_categories
    for all to service_role using (true) with check (true);

drop policy if exists p_faqs_service_role_all on faqs;
create policy p_faqs_service_role_all on faqs
    for all to service_role using (true) with check (true);

drop policy if exists p_support_conversations_service_role_all on support_conversations;
create policy p_support_conversations_service_role_all on support_conversations
    for all to service_role using (true) with check (true);

drop policy if exists p_support_messages_service_role_all on support_messages;
create policy p_support_messages_service_role_all on support_messages
    for all to service_role using (true) with check (true);
