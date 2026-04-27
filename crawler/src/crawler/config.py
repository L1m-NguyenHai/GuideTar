from __future__ import annotations

from pydantic import AliasChoices, Field, model_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_file_encoding="utf-8", extra="ignore")

    database_url: str | None = Field(default=None, validation_alias=AliasChoices("DATABASE_URL", "SUPABASE_DB_URL"))
    user_agent: str = "GuideTarCrawler/0.1 (+https://github.com/L1m-NguyenHai/GuideTar)"
    request_timeout_sec: float = 25.0
    crawl_delay_min_sec: float = 0.6
    crawl_delay_max_sec: float = 1.4

    @model_validator(mode="after")
    def validate_delay_range(self) -> "Settings":
        if self.crawl_delay_min_sec < 0 or self.crawl_delay_max_sec < 0:
            raise ValueError("crawl delay must be non-negative")
        if self.crawl_delay_min_sec > self.crawl_delay_max_sec:
            raise ValueError("crawl_delay_min_sec must be <= crawl_delay_max_sec")
        return self
