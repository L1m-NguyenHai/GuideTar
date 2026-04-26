# GuideTar FE Specification For Building Backend

Last updated: 2026-04-26

Purpose of this file:
- Describe the current frontend behavior only.
- Extract all data needs so a new backend can be built correctly.
- Propose a simple but complete database model for immediate FE integration.

Notes:
- This document does not depend on any old backend.
- The current FE still contains a lot of hardcoded data; the new backend should replace it progressively.

## 1) Frontend Overview

GuideTar is a music learning app (guitar/piano) with these feature groups:
1. Authentication and user profile.
2. Guitar tools, especially AI DeChord.
3. Membership and payments.
4. Favorites and practice analytics.
5. Support, FAQ, and chat.

Frontend stack:
- Flutter.
- HTTP client: `http` package.
- Audio file upload: `file_picker`.
- Audio/video sync playback: `video_player` and `youtube_player_flutter`.

Current FE architecture:
- Screens live in `lib/presentation/pages/**`.
- There is no mature data layer yet; many business rules are inside page widgets.
- If backend responses are stable, FE can integrate quickly.

## 2) Screen Groups And Required Data

## 2.1 Authentication
Related files:
- `lib/presentation/pages/login_page.dart`
- `lib/presentation/pages/register_page.dart`

Frontend data needs:
- Login with email + password.
- Multi-step registration: email -> password -> username.
- Email/username conflict checks.
- Forgot password (currently only guidance UI; backend APIs needed).

Business rules visible in FE:
- Email cannot be empty.
- Password cannot be empty.
- Username cannot be empty and must be unique.

## 2.2 Home, Profile, Weekly Stats, Favorites
Related files:
- `lib/presentation/pages/home_page.dart`
- `lib/presentation/pages/profile_page.dart`
- `lib/presentation/pages/weekly_info_page.dart`
- `lib/presentation/pages/favorite_list.dart`

Frontend data needs:
- Profile info: display name, avatar, badge/rank.
- Daily streak data.
- Weekly practice totals and daily breakdown.
- Favorite songs list.
- Favorite lessons list.

## 2.3 Membership And Payment
Related files:
- `lib/presentation/pages/membership_page.dart`
- `lib/presentation/pages/membership_register_page.dart`
- `lib/presentation/pages/membership_payment_page.dart`
- `lib/presentation/pages/membership_history_page.dart`
- `lib/presentation/pages/membership_update_payment_page.dart`

Frontend data needs:
- Plans list (SOLO/MAESTRO), monthly/yearly prices, discount details.
- Current subscription status.
- Renewal date.
- Payment method.
- Transaction history.
- Cancel subscription flow and result.

## 2.4 Support, FAQ, Chat
Related files:
- `lib/presentation/pages/support_page.dart`
- `lib/presentation/pages/support_account_faqs_page.dart`
- `lib/presentation/pages/support_chat_page.dart`

Frontend data needs:
- FAQ by category.
- Question categories list.
- Support chat history.
- Send new support messages.

Current FE chat has local keyword-based auto-replies; the new backend should replace this with server-side logic.

## 2.5 AI DeChord (Highest Priority)
Related files:
- `lib/presentation/pages/guitar/tools/dechord_page.dart`
- `lib/presentation/pages/guitar/tools/dechord_result_page.dart`

Frontend supports 2 input modes:
1. Upload local MP3 file.
2. Submit YouTube URL.

Frontend needs output for rendering:
- BPM.
- Time signature.
- Chord array aligned by beat.
- Beat timestamp array to highlight chords over time.

## 3) DeChord Contract Currently Used By FE (Must Stay Compatible)

Endpoint used by FE:
- `POST /api/analyze`
- `multipart/form-data`
- FE timeout: 120 seconds

Request fields:
- `include_logs`: string, usually `"false"`
- one of:
  - `file` (MP3)
  - `youtube_url`

Response shape FE can parse:

```json
{
  "beatDetectionResult": {
    "bpm": 120.0,
    "time_signature": 4
  },
  "bpm": 120.0,
  "chords": ["C", "C", "G", "Am", "F"],
  "beats": [0.0, 0.52, 1.04, 1.56, 2.08],
  "chord_count": 5,
  "rawChordCount": 12
}
```

FE parsing rules:
- If `beatDetectionResult.bpm` exists, FE prioritizes it.
- `time_signature` defaults to 4 if missing.
- `chords` and `beats` are the two most important arrays for UI sync.

Recommended error format:

```json
{
  "detail": "Human-readable message for UI",
  "code": "DECHORD_INVALID_INPUT"
}
```

## 4) Hardcoded FE Data That Must Move To DB

1. Demo user and profile data.
2. Favorite songs and lessons.
3. Weekly practice stats.
4. Membership plans, prices, trial details.
5. Payment history.
6. FAQ content and support categories.
7. Song/chord recommendation lists.

## 5) Database Requirements (Simple But Complete)

Goal: a schema that enables fast MVP implementation and can scale later.

## 5.1 Core Tables

1. `users`
- id (uuid, pk)
- email (unique, not null)
- password_hash (not null)
- username (unique, not null)
- created_at, updated_at

2. `user_profiles`
- user_id (pk, fk -> users.id)
- display_name
- avatar_url
- bio
- rank_label
- created_at, updated_at

3. `subscription_plans`
- id (uuid, pk)
- code (unique, e.g. SOLO, MAESTRO)
- name
- price_monthly
- price_yearly
- currency (e.g. VND)
- trial_days
- is_active

4. `user_subscriptions`
- id (uuid, pk)
- user_id (fk)
- plan_id (fk)
- status (active, trial, canceled, expired)
- started_at
- renew_at
- canceled_at

5. `payment_methods`
- id (uuid, pk)
- user_id (fk)
- type (card, qr)
- provider
- masked_label
- is_default
- created_at

6. `payment_transactions`
- id (uuid, pk)
- user_id (fk)
- subscription_id (fk, nullable)
- payment_code (unique)
- amount
- currency
- status (pending, paid, failed, canceled)
- method_type
- paid_at
- created_at

7. `songs`
- id (uuid, pk)
- title
- artist
- duration_seconds
- thumbnail_url
- youtube_url
- created_at

8. `lessons`
- id (uuid, pk)
- title
- description
- level
- thumbnail_url
- created_at

9. `user_favorite_songs`
- user_id (fk)
- song_id (fk)
- created_at
- primary key (user_id, song_id)

10. `user_favorite_lessons`
- user_id (fk)
- lesson_id (fk)
- created_at
- primary key (user_id, lesson_id)

11. `practice_daily_stats`
- id (uuid, pk)
- user_id (fk)
- stat_date (date)
- practice_minutes
- song_count
- lesson_count
- unique (user_id, stat_date)

12. `dechord_analyses`
- id (uuid, pk)
- user_id (fk, nullable for guest)
- source_type (file, youtube)
- source_name
- source_url (nullable)
- bpm
- time_signature
- chord_count
- raw_chord_count
- created_at

13. `dechord_analysis_beats`
- id (bigserial pk)
- analysis_id (fk -> dechord_analyses.id)
- beat_index
- beat_time_seconds
- chord_label

14. `faq_categories`
- id (uuid, pk)
- code
- name
- sort_order

15. `faqs`
- id (uuid, pk)
- category_id (fk)
- question
- answer
- is_active
- sort_order

16. `support_conversations`
- id (uuid, pk)
- user_id (fk)
- status (open, waiting_user, closed)
- created_at
- updated_at

17. `support_messages`
- id (uuid, pk)
- conversation_id (fk)
- sender_type (user, agent, bot)
- message_text
- created_at

## 5.2 Minimum Recommended Indexes

1. `users(email)` unique
2. `users(username)` unique
3. `payment_transactions(payment_code)` unique
4. `payment_transactions(user_id, created_at desc)`
5. `practice_daily_stats(user_id, stat_date)` unique
6. `dechord_analyses(user_id, created_at desc)`
7. `support_messages(conversation_id, created_at)`

## 5.3 Critical Data Rules

1. Email and username must be unique and validated in backend.
2. Password must be stored as hash only (never plain text).
3. Duplicate favorites for the same user/item must be prevented.
4. Payment transactions must have clear status lifecycle.
5. DeChord analysis metadata should be stored for history/replay.

## 6) Quick Mapping: FE Features -> Backend Modules

1. Auth module
- login/register/refresh/forgot password

2. User module
- get/update my profile

3. Membership module
- plans, current subscription, cancel, payment history

4. Payment module
- create payment, confirm payment, payment methods

5. Favorites module
- song favorites, lesson favorites

6. Analytics module
- weekly/daily stats

7. DeChord module
- analyze, analysis history

8. Support module
- faq categories/faqs, conversation/messages

## 7) Minimum API Set For FE End-To-End

Auth:
1. `POST /auth/register`
2. `POST /auth/login`
3. `POST /auth/refresh`
4. `POST /auth/forgot-password`

User/Profile:
1. `GET /users/me`
2. `PATCH /users/me`

DeChord:
1. `POST /api/analyze`
2. `GET /api/analyze/history`

Membership/Payment:
1. `GET /billing/plans`
2. `GET /billing/subscription`
3. `POST /billing/subscription/cancel`
4. `GET /billing/transactions`
5. `POST /billing/pay`

Favorites:
1. `GET /favorites/songs`
2. `POST /favorites/songs/{songId}`
3. `DELETE /favorites/songs/{songId}`
4. `GET /favorites/lessons`
5. `POST /favorites/lessons/{lessonId}`
6. `DELETE /favorites/lessons/{lessonId}`

Analytics:
1. `GET /analytics/weekly`

Support:
1. `GET /support/categories`
2. `GET /support/faqs`
3. `GET /support/conversations/{id}/messages`
4. `POST /support/conversations/{id}/messages`

## 8) Backend Handoff Checklist Before FE Integration

1. Login/register/profile are working with real DB (no hardcoded logic).
2. Favorites are persisted and reloaded correctly per user.
3. Weekly stats are queryable by date.
4. Membership status and payment history are queryable.
5. DeChord API returns the shape FE parser expects.
6. All API errors return JSON with `detail`.
7. Swagger/OpenAPI is published for FE contract alignment.

## 9) Conclusion

If backend is implemented according to this file, FE can progressively remove hardcoded data and run the main flow end-to-end:
- Auth -> Home/Profile -> Favorites/Stats -> Membership/Payment -> Support -> DeChord.

For MVP priority, implement DeChord + Auth + Membership first, then expand to analytics and support.
