import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MetronomePage extends StatefulWidget {
  const MetronomePage({super.key});

  @override
  State<MetronomePage> createState() => _MetronomePageState();
}

enum _MetronomePhase { stopped, countIn, running }

enum _MetronomeSubdivision {
  quarter('Quarter', '1x', 1),
  eighth('Eighth', '1/2', 2),
  triplet('Triplet', '1/3', 3),
  sixteenth('Sixteenth', '1/4', 4);

  const _MetronomeSubdivision(this.label, this.shortLabel, this.factor);

  final String label;
  final String shortLabel;
  final int factor;

  static _MetronomeSubdivision fromName(String value) {
    return _MetronomeSubdivision.values.firstWhere(
      (item) => item.name == value,
      orElse: () => _MetronomeSubdivision.quarter,
    );
  }
}

class _MetronomeTimeSignature {
  const _MetronomeTimeSignature(this.numerator, this.denominator, this.label);

  final int numerator;
  final int denominator;
  final String label;

  static const List<_MetronomeTimeSignature> presets = [
    _MetronomeTimeSignature(2, 4, '2/4'),
    _MetronomeTimeSignature(3, 4, '3/4'),
    _MetronomeTimeSignature(4, 4, '4/4'),
    _MetronomeTimeSignature(6, 8, '6/8'),
    _MetronomeTimeSignature(7, 8, '7/8'),
    _MetronomeTimeSignature(12, 8, '12/8'),
  ];

  static _MetronomeTimeSignature fromString(String value) {
    return presets.firstWhere(
      (item) => item.label == value,
      orElse: () => presets[2],
    );
  }
}

class _MetronomeSettings {
  const _MetronomeSettings({
    required this.bpm,
    required this.timeSignature,
    required this.subdivision,
    required this.accentBeatOne,
    required this.countIn,
    required this.autoStopMinutes,
  });

  final int bpm;
  final _MetronomeTimeSignature timeSignature;
  final _MetronomeSubdivision subdivision;
  final bool accentBeatOne;
  final bool countIn;
  final int autoStopMinutes;

  factory _MetronomeSettings.defaults() {
    return const _MetronomeSettings(
      bpm: 92,
      timeSignature: _MetronomeTimeSignature(4, 4, '4/4'),
      subdivision: _MetronomeSubdivision.quarter,
      accentBeatOne: true,
      countIn: true,
      autoStopMinutes: 0,
    );
  }

  _MetronomeSettings copyWith({
    int? bpm,
    _MetronomeTimeSignature? timeSignature,
    _MetronomeSubdivision? subdivision,
    bool? accentBeatOne,
    bool? countIn,
    int? autoStopMinutes,
  }) {
    return _MetronomeSettings(
      bpm: bpm ?? this.bpm,
      timeSignature: timeSignature ?? this.timeSignature,
      subdivision: subdivision ?? this.subdivision,
      accentBeatOne: accentBeatOne ?? this.accentBeatOne,
      countIn: countIn ?? this.countIn,
      autoStopMinutes: autoStopMinutes ?? this.autoStopMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bpm': bpm,
      'timeSignature': timeSignature.label,
      'subdivision': subdivision.name,
      'accentBeatOne': accentBeatOne,
      'countIn': countIn,
      'autoStopMinutes': autoStopMinutes,
    };
  }

  factory _MetronomeSettings.fromJson(Map<String, dynamic> json) {
    return _MetronomeSettings(
      bpm: (json['bpm'] as num?)?.round() ?? 92,
      timeSignature: _MetronomeTimeSignature.fromString(json['timeSignature'] as String? ?? '4/4'),
      subdivision: _MetronomeSubdivision.fromName(json['subdivision'] as String? ?? 'quarter'),
      accentBeatOne: json['accentBeatOne'] as bool? ?? true,
      countIn: json['countIn'] as bool? ?? true,
      autoStopMinutes: (json['autoStopMinutes'] as num?)?.round() ?? 0,
    );
  }
}

class _MetronomePreset {
  const _MetronomePreset({required this.name, required this.settings});

  final String name;
  final _MetronomeSettings settings;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'settings': settings.toJson(),
    };
  }

  factory _MetronomePreset.fromJson(Map<String, dynamic> json) {
    return _MetronomePreset(
      name: json['name'] as String? ?? 'Preset',
      settings: _MetronomeSettings.fromJson(Map<String, dynamic>.from(json['settings'] as Map? ?? {})),
    );
  }
}

class _MetronomePageState extends State<MetronomePage> with WidgetsBindingObserver {
  static const _settingsKey = 'metronome_settings_v1';
  static const _presetsKey = 'metronome_presets_v1';

  final AudioPlayer _regularPlayer = AudioPlayer();
  final AudioPlayer _accentPlayer = AudioPlayer();
  final Stopwatch _stopwatch = Stopwatch();

  _MetronomeSettings _settings = _MetronomeSettings.defaults();
  List<_MetronomePreset> _presets = [];

  _MetronomePhase _phase = _MetronomePhase.stopped;
  Timer? _tickTimer;
  bool _isLoading = true;
  bool _isBeatHighlighted = false;
  bool _isAudioReady = false;
  Future<void>? _audioPreparationFuture;
  int _currentBeatInBar = 1;
  int _countInRemaining = 0;
  int _tapCount = 0;
  DateTime? _sessionStartedAt;
  String _statusText = 'Nhấn Start để bắt đầu';
  final List<DateTime> _tapTimes = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_initialize());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _tickTimer?.cancel();
    _regularPlayer.dispose();
    _accentPlayer.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _persistState();
      if (_phase != _MetronomePhase.stopped) {
        _stopPlayback(saveMessage: false);
      }
    }
  }

  Future<void> _initialize() async {
    try {
      await _loadState();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
      unawaited(_prepareAudio());
    }
  }

  Future<void> _loadState() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_settingsKey);
    final presetsJson = prefs.getString(_presetsKey);

    _settings = settingsJson == null
        ? _MetronomeSettings.defaults()
        : _MetronomeSettings.fromJson(Map<String, dynamic>.from(jsonDecode(settingsJson) as Map));

    if (presetsJson == null) {
      _presets = _defaultPresets();
      return;
    }

    final parsed = jsonDecode(presetsJson) as List<dynamic>;
    _presets = parsed
        .map((item) => _MetronomePreset.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList(growable: false);
    if (_presets.isEmpty) {
      _presets = _defaultPresets();
    }
  }

  List<_MetronomePreset> _defaultPresets() {
    return [
      _MetronomePreset(name: 'Warm-up', settings: _settings.copyWith(bpm: 72, timeSignature: _MetronomeTimeSignature.presets[2])),
      _MetronomePreset(name: 'Rock 4/4', settings: _settings.copyWith(bpm: 104, timeSignature: _MetronomeTimeSignature.presets[2], subdivision: _MetronomeSubdivision.quarter)),
      _MetronomePreset(name: 'Waltz', settings: _settings.copyWith(bpm: 90, timeSignature: _MetronomeTimeSignature.presets[1], subdivision: _MetronomeSubdivision.quarter)),
    ];
  }

  Future<void> _prepareAudio() async {
    try {
      final regularBytes = _buildClickWav(accent: false);
      final accentBytes = _buildClickWav(accent: true);
      await Future.wait([
        _regularPlayer.setAudioSource(
          AudioSource.uri(Uri.dataFromBytes(regularBytes, mimeType: 'audio/wav')),
          initialPosition: Duration.zero,
          preload: true,
        ),
        _accentPlayer.setAudioSource(
          AudioSource.uri(Uri.dataFromBytes(accentBytes, mimeType: 'audio/wav')),
          initialPosition: Duration.zero,
          preload: true,
        ),
      ]).timeout(const Duration(seconds: 4));
      _isAudioReady = true;
    } catch (_) {
      _isAudioReady = false;
    }
  }

  Uint8List _buildClickWav({required bool accent}) {
    const sampleRate = 44100;
    const durationMs = 48;
    final sampleCount = (sampleRate * durationMs / 1000).round();
    final pcm = Int16List(sampleCount);
    final random = Random(accent ? 19 : 7);
    final frequency = accent ? 1320.0 : 920.0;
    final amplitude = accent ? 0.82 : 0.56;

    for (var i = 0; i < sampleCount; i++) {
      final progress = i / sampleCount;
      final envelope = pow(1 - progress, accent ? 2.2 : 2.6).toDouble();
      final sine = sin(2 * pi * frequency * (i / sampleRate));
      final body = sin(2 * pi * (frequency * 0.52) * (i / sampleRate)) * 0.25;
      final noise = (random.nextDouble() * 2 - 1) * (accent ? 0.08 : 0.05);
      final value = (sine * 0.75 + body + noise) * amplitude * envelope;
      pcm[i] = (value.clamp(-1.0, 1.0) * 32767).round();
    }

    final byteData = ByteData(44 + pcm.lengthInBytes);
    final dataLength = pcm.lengthInBytes;
    _writeAscii(byteData, 0, 'RIFF');
    byteData.setUint32(4, 36 + dataLength, Endian.little);
    _writeAscii(byteData, 8, 'WAVE');
    _writeAscii(byteData, 12, 'fmt ');
    byteData.setUint32(16, 16, Endian.little);
    byteData.setUint16(20, 1, Endian.little);
    byteData.setUint16(22, 1, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, sampleRate * 2, Endian.little);
    byteData.setUint16(32, 2, Endian.little);
    byteData.setUint16(34, 16, Endian.little);
    _writeAscii(byteData, 36, 'data');
    byteData.setUint32(40, dataLength, Endian.little);

    final out = byteData.buffer.asUint8List();
    final pcmBytes = pcm.buffer.asUint8List();
    out.setRange(44, 44 + pcmBytes.length, pcmBytes);
    return out;
  }

  void _writeAscii(ByteData target, int offset, String text) {
    for (var i = 0; i < text.length; i++) {
      target.setUint8(offset + i, text.codeUnitAt(i));
    }
  }

  Future<void> _persistState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_settingsKey, jsonEncode(_settings.toJson()));
    await prefs.setString(_presetsKey, jsonEncode(_presets.map((item) => item.toJson()).toList()));
  }

  Duration _tickInterval() {
    final ticksPerBeat = max(1, _settings.subdivision.factor);
    final bpm = max(30, _settings.bpm);
    final intervalMs = (60000 / (bpm * ticksPerBeat)).round();
    return Duration(milliseconds: max(45, intervalMs));
  }

  int _beatsPerBar() => max(1, _settings.timeSignature.numerator);

  int _countInBeats() => _settings.countIn ? _beatsPerBar() : 0;

  Future<void> _playClick({required bool accent}) async {
    final player = accent ? _accentPlayer : _regularPlayer;
    try {
      if (!_isAudioReady) {
        _audioPreparationFuture ??= _prepareAudio();
        await SystemSound.play(SystemSoundType.click);
        return;
      }
      await player.seek(Duration.zero);
      await player.play();
    } on PlayerException {
      // Ignore transient playback errors and keep the scheduler alive.
    } catch (_) {
      try {
        await SystemSound.play(SystemSoundType.click);
      } catch (_) {
        // Ignore if even the fallback click fails.
      }
    }
  }

  void _pulseBeat() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isBeatHighlighted = true;
    });
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _isBeatHighlighted = false;
      });
    });
  }

  void _scheduleNextTick([Duration? delay]) {
    _tickTimer?.cancel();
    if (_phase == _MetronomePhase.stopped) {
      return;
    }
    _tickTimer = Timer(delay ?? _tickInterval(), _handleTick);
  }

  Future<void> _handleTick() async {
    if (!mounted || _phase == _MetronomePhase.stopped) {
      return;
    }

    final interval = _tickInterval();
    final phase = _phase;

    if (phase == _MetronomePhase.countIn) {
      final beatIndex = _countInBeats() - _countInRemaining;
      final accent = _countInRemaining == _countInBeats() && _settings.accentBeatOne;
      unawaited(_playClick(accent: accent));
      _pulseBeat();
      setState(() {
        _currentBeatInBar = max(1, beatIndex);
        _statusText = 'Count-in $_countInRemaining/${_countInBeats()}';
        _countInRemaining -= 1;
      });
      if (_countInRemaining <= 0) {
        // Beat cuối count-in chính là beat 1 — không cần phát lại.
        // Chỉ chuyển phase và đặt beat tiếp theo là beat 2.
        setState(() {
          _phase = _MetronomePhase.running;
          _currentBeatInBar = _beatsPerBar() > 1 ? 2 : 1;
          _statusText = 'Beat 1/${_beatsPerBar()}';
          _sessionStartedAt = DateTime.now();
        });
        _stopwatch
          ..reset()
          ..start();
        _scheduleNextTick(interval);
        return;
      }
    } else {
      final accent = _currentBeatInBar == 1 && _settings.accentBeatOne;
      unawaited(_playClick(accent: accent));
      _pulseBeat();
      final currentBeat = _currentBeatInBar;
      setState(() {
        _statusText = 'Beat $currentBeat/${_beatsPerBar()}';
        _currentBeatInBar = currentBeat >= _beatsPerBar() ? 1 : currentBeat + 1;
      });

      if (_settings.autoStopMinutes > 0 && _sessionStartedAt != null) {
        final limit = Duration(minutes: _settings.autoStopMinutes);
        if (DateTime.now().difference(_sessionStartedAt!) >= limit) {
          _stopPlayback(saveMessage: true);
          return;
        }
      }
    }

    final elapsedMs = _stopwatch.elapsedMilliseconds;
    final targetMs = (_phase == _MetronomePhase.running ? 1 : 1) * interval.inMilliseconds;
    final delayMs = max(1, targetMs - (elapsedMs % interval.inMilliseconds));
    _scheduleNextTick(Duration(milliseconds: delayMs));
  }

  Future<void> _startPlayback() async {
    if (_isLoading) {
      return;
    }
    if (_phase != _MetronomePhase.stopped) {
      return;
    }

    final countInBeats = _countInBeats();
    setState(() {
      _phase = countInBeats > 0 ? _MetronomePhase.countIn : _MetronomePhase.running;
      _countInRemaining = countInBeats;
      _currentBeatInBar = 1;
      _statusText = countInBeats > 0 ? 'Count-in $_countInRemaining/$countInBeats' : 'Metronome đang chạy';
      _sessionStartedAt = countInBeats > 0 ? null : DateTime.now();
    });

    _stopwatch
      ..reset()
      ..start();
    if (countInBeats == 0) {
      // Phát beat 1 ngay lập tức khi không có count-in
      final accent = _settings.accentBeatOne;
      unawaited(_playClick(accent: accent));
      _pulseBeat();
      setState(() {
        _statusText = 'Beat 1/${_beatsPerBar()}';
        _currentBeatInBar = _beatsPerBar() > 1 ? 2 : 1;
      });
    }
    _scheduleNextTick(_tickInterval());
  }

  void _stopPlayback({required bool saveMessage}) {
    _tickTimer?.cancel();
    _stopwatch.stop();
    _regularPlayer.stop();
    _accentPlayer.stop();
    setState(() {
      _phase = _MetronomePhase.stopped;
      _countInRemaining = 0;
      _currentBeatInBar = 1;
      _sessionStartedAt = null;
      _isBeatHighlighted = false;
      _statusText = saveMessage ? 'Đã dừng metronome' : _statusText;
    });
  }

  void _togglePlayback() {
    if (_phase == _MetronomePhase.stopped) {
      unawaited(_startPlayback());
    } else {
      _stopPlayback(saveMessage: true);
    }
  }

  void _updateSettings(_MetronomeSettings nextSettings, {bool restartIfRunning = true}) {
    final wasRunning = _phase != _MetronomePhase.stopped;
    setState(() {
      _settings = nextSettings;
      _currentBeatInBar = 1;
      _statusText = 'Đã cập nhật thiết lập';
    });
    unawaited(_persistState());
    if (wasRunning && restartIfRunning) {
      _stopPlayback(saveMessage: false);
      unawaited(_startPlayback());
    }
  }

  void _adjustBpm(int delta) {
    final nextBpm = (_settings.bpm + delta).clamp(30, 260).round();
    _updateSettings(_settings.copyWith(bpm: nextBpm));
  }

  void _handleTapTempo() {
    final now = DateTime.now();
    _tapTimes.removeWhere((value) => now.difference(value).inMilliseconds > 1800);
    _tapTimes.add(now);
    _tapCount += 1;

    if (_tapTimes.length < 2) {
      setState(() {
        _statusText = 'Tap tempo: chạm thêm vài nhịp';
      });
      return;
    }

    final intervals = <int>[];
    for (var i = 1; i < _tapTimes.length; i++) {
      intervals.add(_tapTimes[i].difference(_tapTimes[i - 1]).inMilliseconds);
    }
    intervals.sort();
    final median = intervals[intervals.length ~/ 2];
    final bpm = (60000 / max(1, median)).round().clamp(30, 260);
    _updateSettings(_settings.copyWith(bpm: bpm));
    setState(() {
      _statusText = 'Tap tempo: $bpm BPM';
    });
  }

  Future<void> _savePreset() async {
    final controller = TextEditingController(text: 'Preset ${_presets.length + 1}');
    final presetName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191919),
          title: Text(
            'Lưu preset',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tên preset',
              hintStyle: TextStyle(color: Color(0xFF8E8E8E)),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(controller.text.trim()),
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    final name = presetName == null || presetName.isEmpty ? controller.text.trim() : presetName;
    if (name.isEmpty) {
      return;
    }

    final nextPresets = [
      ..._presets,
      _MetronomePreset(name: name, settings: _settings),
    ];
    setState(() {
      _presets = nextPresets;
      _statusText = 'Đã lưu preset "$name"';
    });
    await _persistState();
  }

  void _applyPreset(_MetronomePreset preset) {
    _updateSettings(preset.settings);
    setState(() {
      _statusText = 'Đã áp dụng preset ${preset.name}';
    });
  }

  Future<void> _deletePreset(int index) async {
    if (index < 0 || index >= _presets.length) {
      return;
    }
    final preset = _presets[index];
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF191919),
          title: Text(
            'Xóa preset?',
            style: GoogleFonts.plusJakartaSans(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: Text(
            'Xóa preset "${preset.name}" khỏi thiết bị này?',
            style: GoogleFonts.manrope(color: const Color(0xFFADAAAA)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: const Color(0xFFE35252)),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Xóa'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    setState(() {
      _presets = [..._presets]..removeAt(index);
      _statusText = 'Đã xóa preset ${preset.name}';
    });
    await _persistState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFFF923E)),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 18),
                    _buildBeatStage(),
                    const SizedBox(height: 18),
                    _buildTransportBar(),
                    const SizedBox(height: 16),
                    _buildTempoCard(),
                    const SizedBox(height: 14),
                    _buildRhythmCard(),
                    const SizedBox(height: 14),
                    _buildAdvancedCard(),
                    const SizedBox(height: 14),
                    _buildPresetCard(),
                    const SizedBox(height: 14),
                    _buildStatusCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            }
          },
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Metronome',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Nhịp chuẩn, tap tempo, count-in và preset lưu local',
                style: GoogleFonts.manrope(
                  color: const Color(0xFFB1AEAE),
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBeatStage() {
    final beatLabel = _phase == _MetronomePhase.countIn
        ? 'Count-in'
        : _phase == _MetronomePhase.running
            ? 'Beat $_currentBeatInBar'
            : 'Ready';
    final beatHint = _phase == _MetronomePhase.countIn
        ? 'Bắt đầu vào nhịp sau count-in'
        : _phase == _MetronomePhase.running
            ? '${_settings.timeSignature.label} · ${_settings.subdivision.label}'
            : 'Chạm Start để phát nhịp';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1C1C1C), Color(0xFF121212)],
        ),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
      ),
      child: Column(
        children: [
          AnimatedScale(
            duration: const Duration(milliseconds: 120),
            scale: _isBeatHighlighted ? 1.06 : 1.0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 162,
              height: 162,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isBeatHighlighted ? const Color.fromRGBO(255, 146, 62, 0.24) : const Color(0xFF0F0F0F),
                border: Border.all(
                  color: _isBeatHighlighted
                      ? const Color.fromRGBO(255, 146, 62, 0.5)
                      : const Color.fromRGBO(255, 255, 255, 0.08),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: _isBeatHighlighted
                        ? const Color.fromRGBO(255, 146, 62, 0.24)
                        : Colors.black.withValues(alpha: 0.25),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    beatLabel,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${_settings.bpm} BPM',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFFD262),
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            beatHint,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: const Color(0xFFB1AEAE),
              fontSize: 13,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportBar() {
    final isRunning = _phase != _MetronomePhase.stopped;
    return Row(
      children: [
        Expanded(
          child: _TransportButton(
            icon: Icons.play_arrow_rounded,
            label: isRunning ? 'Stop' : 'Start',
            filled: true,
            onTap: _togglePlayback,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _TransportButton(
            icon: Icons.album_rounded,
            label: 'Tap tempo',
            filled: false,
            onTap: _handleTapTempo,
          ),
        ),
      ],
    );
  }

  Widget _buildTempoCard() {
    return _SettingCard(
      title: 'Tempo',
      subtitle: 'Chỉnh BPM và bước thay đổi nhanh',
      child: Column(
        children: [
          Row(
            children: [
              _RoundStepButton(icon: Icons.remove, onTap: () => _adjustBpm(-1)),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131313),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${_settings.bpm}',
                        style: GoogleFonts.plusJakartaSans(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'BPM',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFB1AEAE),
                          fontSize: 12,
                          letterSpacing: 2,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _RoundStepButton(icon: Icons.add, onTap: () => _adjustBpm(1)),
            ],
          ),
          const SizedBox(height: 14),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              activeTrackColor: const Color(0xFFFF923E),
              inactiveTrackColor: const Color.fromRGBO(255, 255, 255, 0.08),
              thumbColor: const Color(0xFFFF923E),
              overlayColor: const Color.fromRGBO(255, 146, 62, 0.16),
            ),
            child: Slider(
              min: 30,
              max: 260,
              value: _settings.bpm.toDouble(),
              onChanged: (value) {
                _updateSettings(_settings.copyWith(bpm: value.round()));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRhythmCard() {
    return _SettingCard(
      title: 'Nhịp và subdivision',
      subtitle: 'Time signature và phân nhịp của click',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Time signature',
            style: GoogleFonts.manrope(color: const Color(0xFFB1AEAE), fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _MetronomeTimeSignature.presets)
                _ChoiceChip(
                  label: item.label,
                  selected: item.label == _settings.timeSignature.label,
                  onTap: () => _updateSettings(_settings.copyWith(timeSignature: item)),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            'Subdivision',
            style: GoogleFonts.manrope(color: const Color(0xFFB1AEAE), fontSize: 12, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final item in _MetronomeSubdivision.values)
                _ChoiceChip(
                  label: item.label,
                  selected: item == _settings.subdivision,
                  onTap: () => _updateSettings(_settings.copyWith(subdivision: item)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedCard() {
    return _SettingCard(
      title: 'Nâng cao',
      subtitle: 'Accent, count-in và auto-stop',
      child: Column(
        children: [
          _SwitchRow(
            title: 'Accent beat 1',
            subtitle: 'Làm nổi bật phách đầu ô nhịp',
            value: _settings.accentBeatOne,
            onChanged: (value) => _updateSettings(_settings.copyWith(accentBeatOne: value)),
          ),
          const SizedBox(height: 14),
          _SwitchRow(
            title: 'Count-in',
            subtitle: 'Đếm trước một ô nhịp trước khi chạy',
            value: _settings.countIn,
            onChanged: (value) => _updateSettings(_settings.copyWith(countIn: value)),
          ),
          const SizedBox(height: 14),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Auto-stop',
              style: GoogleFonts.manrope(color: const Color(0xFFB1AEAE), fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final minutes in const [0, 1, 5, 10, 15])
                _ChoiceChip(
                  label: minutes == 0 ? 'Off' : '${minutes}m',
                  selected: minutes == _settings.autoStopMinutes,
                  onTap: () => _updateSettings(_settings.copyWith(autoStopMinutes: minutes)),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetCard() {
    return _SettingCard(
      title: 'Presets',
      subtitle: 'Lưu và áp dụng nhanh thiết lập hiện tại',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final preset in _presets)
                GestureDetector(
                  onTap: () => _applyPreset(preset),
                  onLongPress: () => _deletePreset(_presets.indexOf(preset)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.08)),
                    ),
                    child: Text(
                      preset.name,
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: _TransportButton(
              icon: Icons.bookmark_add_rounded,
              label: 'Lưu preset hiện tại',
              filled: false,
                onTap: _savePreset,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF161616),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color.fromRGBO(255, 146, 62, 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: const Icon(Icons.graphic_eq_rounded, color: Color(0xFFFF923E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _statusText,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tap tempo: $_tapCount · Presets: ${_presets.length}',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFB1AEAE),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({required this.title, required this.subtitle, required this.child});

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF171717),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              color: const Color(0xFFB1AEAE),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _TransportButton extends StatelessWidget {
  const _TransportButton({required this.icon, required this.label, required this.onTap, required this.filled});

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 54,
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFF923E) : const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: filled ? const Color.fromRGBO(255, 146, 62, 0.0) : const Color.fromRGBO(255, 255, 255, 0.06),
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: filled ? const Color(0xFF0D0D0D) : Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: filled ? const Color(0xFF0D0D0D) : Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundStepButton extends StatelessWidget {
  const _RoundStepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
        ),
        alignment: Alignment.center,
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? const Color.fromRGBO(255, 146, 62, 0.16) : const Color(0xFF141414),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color.fromRGBO(255, 146, 62, 0.34) : const Color.fromRGBO(255, 255, 255, 0.06),
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            color: selected ? const Color(0xFFFFD262) : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.title, required this.subtitle, required this.value, required this.onChanged});

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFB1AEAE),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: const Color(0xFFFF923E),
            activeTrackColor: const Color.fromRGBO(255, 146, 62, 0.25),
            inactiveThumbColor: const Color(0xFF9A9A9A),
            inactiveTrackColor: const Color.fromRGBO(255, 255, 255, 0.12),
          ),
        ],
      ),
    );
  }
}
