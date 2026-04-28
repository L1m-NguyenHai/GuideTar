from __future__ import annotations

import io
import math
from dataclasses import dataclass
from typing import Iterable

import numpy as np
import soundfile as sf

_NOTE_TO_SEMITONE = {
    'C': 0,
    'C#': 1,
    'Db': 1,
    'D': 2,
    'D#': 3,
    'Eb': 3,
    'E': 4,
    'Fb': 4,
    'E#': 5,
    'F': 5,
    'F#': 6,
    'Gb': 6,
    'G': 7,
    'G#': 8,
    'Ab': 8,
    'A': 9,
    'A#': 10,
    'Bb': 10,
    'B': 11,
    'Cb': 11,
}

_SEMITONE_TO_NOTE = ['C', 'C#', 'D', 'Eb', 'E', 'F', 'F#', 'G', 'Ab', 'A', 'Bb', 'B']
_CHORD_INTERVALS = {
    'maj': [0, 4, 7],
    'min': [0, 3, 7],
    'dim': [0, 3, 6],
    'aug': [0, 4, 8],
    'sus2': [0, 2, 7],
    'sus4': [0, 5, 7],
    'maj7': [0, 4, 7, 11],
    'min7': [0, 3, 7, 10],
    '7': [0, 4, 7, 10],
}


def _parse_note_label(value: str) -> tuple[str, int]:
    trimmed = value.strip()
    if not trimmed:
        raise ValueError('Note value is empty')

    letter = trimmed[0].upper()
    accidental = ''
    octave_text = ''
    if len(trimmed) >= 2 and trimmed[1] in ['#', 'b']:
        accidental = trimmed[1]
        octave_text = trimmed[2:]
    else:
        octave_text = trimmed[1:]

    note_name = f'{letter}{accidental}'
    if note_name not in _NOTE_TO_SEMITONE:
        raise ValueError(f'Unsupported note: {value}')

    octave = int(octave_text) if octave_text else 4
    return note_name, octave


def _note_to_frequency(note_name: str, octave: int) -> float:
    semitone = _NOTE_TO_SEMITONE[note_name]
    midi_note = (octave + 1) * 12 + semitone
    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))


def _midi_to_frequency(midi_note: int) -> float:
    return 440.0 * (2.0 ** ((midi_note - 69) / 12.0))


def _build_envelope(length: int, sample_rate: int) -> np.ndarray:
    attack = max(1, int(sample_rate * 0.02))
    release = max(1, int(sample_rate * 0.06))
    sustain = max(0, length - attack - release)
    envelope = np.ones(length, dtype=np.float32)
    envelope[:attack] = np.linspace(0.0, 1.0, attack, dtype=np.float32)
    if sustain > 0:
        envelope[attack:attack + sustain] = 1.0
    envelope[-release:] = np.linspace(1.0, 0.0, release, dtype=np.float32)
    return envelope


def _apply_fade(samples: np.ndarray, sample_rate: int) -> np.ndarray:
    envelope = _build_envelope(len(samples), sample_rate)
    return samples * envelope


def _sine_wave(frequency: float, duration_ms: int, sample_rate: int, gain: float) -> np.ndarray:
    sample_count = int(sample_rate * (duration_ms / 1000.0))
    time_axis = np.linspace(0.0, duration_ms / 1000.0, sample_count, endpoint=False, dtype=np.float32)
    base = np.sin(2.0 * math.pi * frequency * time_axis)
    harmonic = 0.28 * np.sin(2.0 * math.pi * frequency * 2.0 * time_axis)
    return (gain * (base + harmonic)).astype(np.float32)


def _mix_frequencies(frequencies: Iterable[float], duration_ms: int, sample_rate: int, gain: float) -> np.ndarray:
    frequencies = list(frequencies)
    if not frequencies:
        frequencies = [440.0]

    sample_count = int(sample_rate * (duration_ms / 1000.0))
    time_axis = np.linspace(0.0, duration_ms / 1000.0, sample_count, endpoint=False, dtype=np.float32)
    wave = np.zeros(sample_count, dtype=np.float32)
    for frequency in frequencies:
        wave += np.sin(2.0 * math.pi * frequency * time_axis)
        wave += 0.18 * np.sin(2.0 * math.pi * frequency * 2.0 * time_axis)

    wave /= max(1, len(frequencies))
    return (gain * wave).astype(np.float32)


def _parse_chord_label(value: str) -> tuple[str, str]:
    trimmed = value.strip()
    if ':' in trimmed:
        root_text, quality = trimmed.split(':', 1)
    else:
        root_text, quality = trimmed, 'maj'
    root_text = root_text.strip()
    # Capitalize only the root letter; preserve accidental case ('b' must stay lowercase, '#' stays as-is)
    if len(root_text) >= 2 and root_text[1] in ('#', 'b'):
        root_text = root_text[0].upper() + root_text[1:]
    else:
        root_text = root_text[0].upper() if root_text else root_text
    quality = quality.strip().lower() or 'maj'
    if root_text not in _NOTE_TO_SEMITONE:
        raise ValueError(f'Unsupported chord root: {value}')
    return root_text, quality


def _chord_frequencies(chord_label: str) -> list[float]:
    root_text, quality = _parse_chord_label(chord_label)
    intervals = _CHORD_INTERVALS.get(quality, _CHORD_INTERVALS['maj'])
    root_midi = 60 + _NOTE_TO_SEMITONE[root_text]
    return [_midi_to_frequency(root_midi + interval) for interval in intervals]


def _interval_frequencies(interval_label: str, secondary_value: str | None) -> list[float]:
    base_note = secondary_value or 'C4'
    base_name, base_octave = _parse_note_label(base_note)
    base_frequency = _note_to_frequency(base_name, base_octave)

    interval_text = interval_label.strip().lower()
    is_descending = interval_text.endswith('-desc')
    if is_descending:
        interval_text = interval_text.removesuffix('-desc')

    interval_map = {
        'm2': 1,
        '2': 2,
        'm3': 3,
        '3': 4,
        '4': 5,
        'p4': 5,
        '5': 7,
        'p5': 7,
        'm6': 8,
        '6': 9,
        'm7': 10,
        '7': 11,
        '8': 12,
        'octave': 12,
    }
    semitones = interval_map.get(interval_text, 4)
    if is_descending:
        target_frequency = base_frequency / (2.0 ** (semitones / 12.0))
    else:
        target_frequency = base_frequency * (2.0 ** (semitones / 12.0))
    return [base_frequency, target_frequency]


def _render_wav(samples: np.ndarray, sample_rate: int) -> bytes:
    clipped = np.clip(samples, -1.0, 1.0)
    buffer = io.BytesIO()
    sf.write(buffer, clipped, sample_rate, format='WAV', subtype='PCM_16')
    return buffer.getvalue()


def generate_ear_training_audio(
    mode: str,
    value: str,
    secondary_value: str | None = None,
    duration_ms: int = 1400,
    sample_rate: int = 44100,
    gain: float = 0.22,
) -> bytes:
    normalized_mode = mode.strip().lower()
    if normalized_mode == 'chord':
        samples = _mix_frequencies(_chord_frequencies(value), duration_ms, sample_rate, gain)
    elif normalized_mode == 'note':
        note_name, octave = _parse_note_label(value)
        samples = _sine_wave(_note_to_frequency(note_name, octave), duration_ms, sample_rate, gain)
    elif normalized_mode == 'interval':
        samples = _mix_frequencies(_interval_frequencies(value, secondary_value), duration_ms, sample_rate, gain)
    else:
        raise ValueError(f'Unsupported ear training mode: {mode}')

    samples = _apply_fade(samples, sample_rate)
    return _render_wav(samples, sample_rate)
