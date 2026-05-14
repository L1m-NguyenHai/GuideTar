import 'dart:async';

import 'package:record/record.dart';
import 'package:flutter/foundation.dart';

import 'pitch_detector.dart';

class TunerService {
  final AudioRecorder _recorder = AudioRecorder();
  final PitchDetector _detector = PitchDetector();
  StreamSubscription<RecordState>? _stateSub;
  StreamSubscription<List<int>>? _audioSub;
  bool _isListening = false;

  final _pitchController = StreamController<PitchResult?>.broadcast();
  Stream<PitchResult?> get pitchStream => _pitchController.stream;
  PitchResult? _lastResult;
  PitchResult? get lastResult => _lastResult;

  bool get isListening => _isListening;

  Future<bool> requestPermission() async {
    return await _recorder.hasPermission();
  }

  Future<void> start() async {
    if (_isListening) return;

    try {
      final hasPerm = await _recorder.hasPermission();
      if (!hasPerm) {
        debugPrint('No microphone permission');
        return;
      }

      final stream = await _recorder.startStream(const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        numChannels: 1,
        sampleRate: 44100,
      ));

      _isListening = true;
      _audioSub = stream.listen(
        (data) => _onAudioData(data),
        onError: (e) => debugPrint('Audio error: $e'),
      );

      _stateSub = _recorder.onStateChanged().listen((state) {
        debugPrint('Recorder state: $state');
      });
    } catch (e) {
      debugPrint('Failed to start tuner: $e');
    }
  }

  Future<void> stop() async {
    if (!_isListening) return;
    _isListening = false;
    await _audioSub?.cancel();
    await _stateSub?.cancel();
    try {
      await _recorder.stop();
    } catch (_) {}
  }

  void _onAudioData(List<int> data) {
    final samples = _bytesToFloat(data);
    final result = _detector.process(samples);
    if (result != null && result.confidence > 0.8) {
      _lastResult = result;
      _pitchController.add(result);
    }
  }

  List<double> _bytesToFloat(List<int> bytes) {
    final samples = <double>[];
    for (int i = 0; i + 1 < bytes.length; i += 2) {
      final sample = (bytes[i] | (bytes[i + 1] << 8)).toSigned(16);
      samples.add(sample / 32768.0);
    }
    return samples;
  }

  void dispose() {
    stop();
    _pitchController.close();
  }
}
