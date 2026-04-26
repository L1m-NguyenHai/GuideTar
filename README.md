# GuideTar - Chạy Frontend + Backend

## Yêu cầu

- Flutter SDK (cho FE)
- `uv` (cho BE)
- `ffmpeg` có trong `PATH` (cho BE)

## 1) Khởi động Backend (FastAPI)

Mở terminal 1:

```bash
cd backend
uv sync
uv run main
```

Backend chạy tại: `http://127.0.0.1:8000`

## 2) Khởi động Frontend (Flutter)

Mở terminal 2:

```bash
cd frontend
flutter pub get
flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000
```

## Ghi chú

- Android emulator dùng localhost backend qua `10.0.2.2`. Khi đó chạy FE với:

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://10.0.2.2:8000
```

- Nếu muốn bật chat support gọi BE thật:

```bash
flutter run --dart-define=BACKEND_BASE_URL=http://127.0.0.1:8000 --dart-define=SUPPORT_CONVERSATION_ID=<conversation_id>
```
