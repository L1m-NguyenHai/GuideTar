def main() -> None:
    import os
    import uvicorn

    reload_flag = os.getenv("UVICORN_RELOAD", "true").strip().lower() in {"1", "true", "yes", "on"}
    workers_str = os.getenv("UVICORN_WORKERS", "").strip()

    kwargs: dict[str, object] = {
        "host": os.getenv("UVICORN_HOST", "127.0.0.1"),
        "port": int(os.getenv("UVICORN_PORT", "8000")),
    }

    if reload_flag:
        kwargs["reload"] = True
    else:
        kwargs["workers"] = int(workers_str) if workers_str.isdigit() else 1

    uvicorn.run("app.main:app", **kwargs)


if __name__ == "__main__":
    main()
