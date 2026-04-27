# Copilot Instructions for GuideTar

## Build, test, and lint commands

### Repository root (run FE + BE together)
- Start backend:
  - `cd backend`
  - `uv sync`
  - `uv run main`
- Start frontend:
  - `cd frontend`
  - `flutter pub get`
  - `flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000`

### Backend (`backend/`)
- Install deps: `uv sync`
- Run API: `uv run main.py` (or `uv run main` from repo docs)
- Run chord model script directly (inside model repo):
  - `uv run python chord_recognition.py <audio.mp3> <out.lab> <dict>`
- Tests/lint:
  - No backend test suite or linter command is currently configured in repo docs/config.

### Frontend (`frontend/`)
- Install deps: `flutter pub get`
- Run app:
  - Localhost backend: `flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000`
  - Android emulator backend: `flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000`
- Lint/static analysis: `flutter analyze`
- Test suite: `flutter test`
- Single test file: `flutter test test/widget_test.dart`
- Single test by name: `flutter test --plain-name "<test name>" test/widget_test.dart`
- Build artifacts:
  - `flutter build apk`
  - `flutter build ios`
  - `flutter build web`

## High-level architecture

GuideTar is a Flutter frontend + FastAPI backend in one repo.

- **Frontend (`frontend/`)**
  - Entry point: `lib/main.dart`
  - App shell flow: `lib/presentation/pages/app_root_page.dart` (intro animation -> login)
  - API client: `lib/data/backend_api.dart`
  - Session state: `lib/data/auth_session.dart` (in-memory tokens/user)
  - DeChord UI flow: `lib/presentation/pages/guitar/tools/dechord_page.dart` -> result page

- **Backend (`backend/`)**
  - ASGI app: `app/main.py`
  - Process entrypoint: `main.py` (starts uvicorn on 127.0.0.1:8000)
  - API router composition: `app/api/v1/router.py`
  - Endpoint modules: `app/api/v1/endpoints/*`
  - Auth dependency + bearer parsing: `app/api/dependencies.py`
  - DB pool wrapper: `app/core/database.py` (asyncpg pool, optional startup if URL missing)
  - DeChord pipeline: `app/services/dechord_service.py`
    - accepts uploaded MP3 or YouTube URL
    - uses `madmom` for beat detection
    - shells out to external `Models/chord-cnn-lstm-model/chord_recognition.py`
    - builds beat/chord-aligned response used by frontend playback UI

- **Database schema/migrations**
  - SQL migrations in `backend/supabase/migrations/`
  - Initial schema includes auth/profile, membership/payments, favorites, analytics, DeChord history, support FAQ/chat.
  - RLS/index baseline migration exists and enables service-role policies.

## Key conventions specific to this repository

- DeChord request contract is multipart `POST /api/analyze` with either `file` or `youtube_url` (not both required). Keep response keys compatible with FE parsing (`chords`, `beats`, `beatDetectionResult`, `rawChordCount`, etc.).
- Backend defaults model path to `backend/Models/chord-cnn-lstm-model` (derived in code), but endpoint allows overriding `model_repo`.
- FE backend base URL strategy is centralized in `BackendApi`: prefer `--dart-define=BACKEND_BASE_URL=...`; if not provided, code falls back to Android emulator `10.0.2.2` then `localhost`.
- Auth is JWT bearer-based on backend, but FE session is memory-only (`AuthSession` static fields). Do not assume token persistence across app restarts unless explicitly adding storage.
- Backend is designed to run without DB if `SUPABASE_DB_URL`/`DATABASE_URL` is missing; DB-dependent endpoints then fail via `require_db()` with HTTP 503.
- Password hashing intentionally uses `pbkdf2_sha256` in `app/core/security.py` (project-specific choice documented in code comments).
- Support/billing/favorites endpoints are SQL-first with direct asyncpg queries (no ORM layer); follow existing query style and return plain dict/list payloads.
- Project has MCP server config at repo root (`.mcp.json`) with `figma` and `supabase`; keep this in mind for design/database-assisted tasks.