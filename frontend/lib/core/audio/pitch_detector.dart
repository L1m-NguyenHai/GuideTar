import 'dart:math';

class PitchResult {
  final double frequency;
  final String note;
  final int octave;
  final double cents;
  final double confidence;

  const PitchResult({
    required this.frequency,
    required this.note,
    required this.octave,
    required this.cents,
    required this.confidence,
  });
}

class PitchDetector {
  final int sampleRate;
  final int windowSize;
  final double threshold;

  PitchDetector({
    this.sampleRate = 44100,
    this.windowSize = 2048,
    this.threshold = 0.1,
  });

  static const _noteNames = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];

  static const _stringFrequencies = [
    82.41,  // E2
    110.00, // A2
    146.83, // D3
    196.00, // G3
    246.94, // B3
    329.63, // E4
  ];

  PitchResult? process(List<double> samples) {
    if (samples.length < windowSize) return null;

    final buffer = samples.sublist(0, windowSize);
    final power = _squareSum(buffer);
    if (power < 1e-6) return null;

    final diff = _difference(buffer);
    final tau = _absoluteMinimum(diff);
    if (tau < 0 || tau >= windowSize ~/ 2) return null;

    final interpolated = _parabolicInterpolation(diff, tau);
    final freq = sampleRate / interpolated;
    if (freq < 30 || freq > 2000) return null;

    final confidence = 1.0 - diff[tau];
    return _freqToNote(freq, confidence);
  }

  double _squareSum(List<double> x) {
    double sum = 0;
    for (final v in x) {
      sum += v * v;
    }
    return sum;
  }

  List<double> _difference(List<double> x) {
    final n = x.length;
    final diff = List.filled(n ~/ 2, 0.0);
    double runningSum = 0;

    for (int tau = 0; tau < n ~/ 2; tau++) {
      double sum = 0;
      for (int i = 0; i < n ~/ 2; i++) {
        final delta = x[i] - x[i + tau];
        sum += delta * delta;
      }
      runningSum += sum;
      diff[tau] = runningSum > 0 ? sum * tau / runningSum : 0;
    }
    return diff;
  }

  int _absoluteMinimum(List<double> diff) {
    int tau = 0;
    for (int i = 1; i < diff.length; i++) {
      if (diff[i] < diff[tau]) {
        tau = i;
      }
    }
    return tau > 0 && diff[tau] < threshold ? tau : -1;
  }

  double _parabolicInterpolation(List<double> diff, int tau) {
    if (tau < 1 || tau >= diff.length - 1) return tau.toDouble();
    final a = diff[tau - 1];
    final b = diff[tau];
    final c = diff[tau + 1];
    final denom = a - 2 * b + c;
    if (denom.abs() < 1e-12) return tau.toDouble();
    return tau + (c - a) / (2 * denom);
  }

  PitchResult _freqToNote(double freq, double confidence) {
    final midi = 12 * (log(freq / 440) / log(2)) + 69;
    final midiRounded = midi.round();
    final cents = (midi - midiRounded) * 100;
    final noteIdx = midiRounded % 12;
    final octave = (midiRounded ~/ 12) - 1;

    return PitchResult(
      frequency: freq,
      note: _noteNames[noteIdx],
      octave: octave,
      cents: cents,
      confidence: confidence,
    );
  }

  static int closestStringIndex(double freq) {
    int best = 0;
    double bestDiff = double.infinity;
    for (int i = 0; i < _stringFrequencies.length; i++) {
      final diff = (freq - _stringFrequencies[i]).abs();
      if (diff < bestDiff) {
        bestDiff = diff;
        best = i;
      }
    }
    return best;
  }

  static double stringFrequency(int index) => _stringFrequencies[index];
}
