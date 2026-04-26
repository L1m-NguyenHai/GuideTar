# GuideTarBackend

Independent FastAPI backend for:
- Beat detection with `madmom`
- Chord detection with `Chord-CNN-LSTM` model repo
- Auth/Profile/Billing/Favorites/Analytics/Support APIs for FE integration

This project is independent from ChordMiniApp code. It only executes the external model repo via command line.

## Requirements

- `uv` installed
- `ffmpeg` available in PATH
- A local clone of `chord-cnn-lstm-model` that can run:
  - `uv run python chord_recognition.py <audio.mp3> <out.lab> <dict>`

## Install

```bash
uv sync
```

## Environment

Copy `.env.example` and fill values:

```bash
SUPABASE_DB_URL=postgresql://postgres:<password>@db.<project-ref>.supabase.co:5432/postgres
JWT_SECRET_KEY=<strong-secret>
JWT_ALGORITHM=HS256
JWT_ACCESS_EXPIRE_MINUTES=30
JWT_REFRESH_EXPIRE_DAYS=30
```

## Run API

```bash
uv run main.py
```

Server runs at `http://localhost:8000`.

## Project Structure

```text
app/
  api/
    dependencies.py
    v1/
      endpoints/
      router.py
  core/
    database.py
    security.py
  schemas/
  services/
  main.py
```

## Endpoints

- `GET /health`
- `POST /api/analyze`
- `GET /api/analyze/history`

Auth:
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/forgot-password`

User:
- `GET /users/me`
- `PATCH /users/me`

Billing:
- `GET /billing/plans`
- `GET /billing/subscription`
- `POST /billing/subscription/cancel`
- `GET /billing/transactions`
- `POST /billing/pay`

Favorites:
- `GET /favorites/songs`
- `POST /favorites/songs/{songId}`
- `DELETE /favorites/songs/{songId}`
- `GET /favorites/lessons`
- `POST /favorites/lessons/{lessonId}`
- `DELETE /favorites/lessons/{lessonId}`

Analytics:
- `GET /analytics/weekly`

Support:
- `GET /support/categories`
- `GET /support/faqs`
- `GET /support/conversations/{id}/messages`
- `POST /support/conversations/{id}/messages`

`/api/analyze` form fields:
- `file` (optional, MP3)
- `youtube_url` (optional, YouTube video link)
- `chord_dict` (optional, default `submission`)
- `model_repo` (optional path, default `./Models/chord-cnn-lstm-model`)
- `include_logs` (optional boolean)

Provide either `file` or `youtube_url`.

Response contains:
- `rawChords` (raw `{start, end, chord}` spans from the model output)
- `chords` (grid-ready visual chord labels with padding/shift applied)
- `beats` (visual beat timestamps aligned to the grid)
- `synchronizedChords` (beat-aligned chord sequence)
- `beatDetectionResult` (`time_signature`, `bpm`, `paddingCount`, `shiftCount`, `beatShift`)
- `originalAudioMapping` and `animationMapping` for UI sync
- `lab` (full `.lab` content)
