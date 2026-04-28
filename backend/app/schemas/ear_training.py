from __future__ import annotations

from pydantic import BaseModel, Field


class EarTrainingSoundRequest(BaseModel):
    mode: str = Field(pattern=r"^(chord|note|interval)$")
    value: str
    secondary_value: str | None = None
    duration_ms: int = Field(default=1400, ge=300, le=5000)
    sample_rate: int = Field(default=44100, ge=8000, le=96000)
    gain: float = Field(default=0.22, ge=0.05, le=1.0)
