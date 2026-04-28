from __future__ import annotations

from fastapi import APIRouter, HTTPException
from fastapi.responses import Response

from app.schemas.ear_training import EarTrainingSoundRequest
from app.services.ear_training_service import generate_ear_training_audio

router = APIRouter(tags=['ear-training'])


@router.post('/api/ear-training/sound')
async def generate_sound(request: EarTrainingSoundRequest) -> Response:
    try:
        audio_bytes = generate_ear_training_audio(
            mode=request.mode,
            value=request.value,
            secondary_value=request.secondary_value,
            duration_ms=request.duration_ms,
            sample_rate=request.sample_rate,
            gain=request.gain,
        )
    except ValueError as error:
        raise HTTPException(status_code=400, detail=str(error)) from error

    return Response(
        content=audio_bytes,
        media_type='audio/wav',
        headers={
            'Content-Disposition': 'inline; filename="ear-training.wav"',
            'Cache-Control': 'no-store',
        },
    )
