import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:just_audio/just_audio.dart';

import 'package:guidetar/data/backend_api.dart';

enum _EarTrainingMode {
  chord,
  note,
  interval,
}

enum _EarTrainingDifficulty {
  easy,
  normal,
  hard,
}

class GuitarEarTrainingPage extends StatefulWidget {
  const GuitarEarTrainingPage({super.key});

  @override
  State<GuitarEarTrainingPage> createState() => _GuitarEarTrainingPageState();
}

class _GuitarEarTrainingPageState extends State<GuitarEarTrainingPage> {
  final math.Random _random = math.Random();
  final AudioPlayer _player = AudioPlayer();

  StreamSubscription<PlayerState>? _playerStateSubscription;

  _EarTrainingMode _mode = _EarTrainingMode.chord;
  _EarTrainingDifficulty _difficulty = _EarTrainingDifficulty.easy;
  _EarTrainingQuestion? _question;
  Uint8List? _audioBytes;

  bool _isLoadingQuestion = true;
  bool _isPlaying = false;
  bool _isAnswered = false;
  bool _hasFinishedSession = false;

  int _currentQuestionIndex = 1;
  int _score = 0;
  int _streak = 0;
  int _bestStreak = 0;
  int _correctCount = 0;

  String? _selectedOption;
  String? _feedbackMessage;
  bool? _feedbackIsCorrect;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _playerStateSubscription = _player.playerStateStream.listen((state) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPlaying = state.playing;
      });
    });
    unawaited(_prepareQuestion(autoPlay: false));
  }

  @override
  void dispose() {
    _playerStateSubscription?.cancel();
    _player.dispose();
    super.dispose();
  }

  Future<void> _prepareQuestion({required bool autoPlay}) async {
    if (!mounted) {
      return;
    }

    final question = _buildQuestion();
    setState(() {
      _isLoadingQuestion = true;
      _loadError = null;
      _isAnswered = false;
      _selectedOption = null;
      _feedbackMessage = null;
      _feedbackIsCorrect = null;
      _question = question;
      _audioBytes = null;
    });

    try {
      final audioBytes = await BackendApi.generateEarTrainingSound(
        mode: question.backendMode,
        value: question.backendValue,
        secondaryValue: question.secondaryBackendValue,
        durationMs: _difficulty.durationMs,
        gain: _difficulty.gain,
      );

      if (!mounted) {
        return;
      }

      await _player.setAudioSource(
        AudioSource.uri(Uri.dataFromBytes(audioBytes, mimeType: 'audio/wav')),
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _audioBytes = audioBytes;
        _isLoadingQuestion = false;
        _loadError = null;
      });

      if (autoPlay) {
        await _player.play();
      }
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isLoadingQuestion = false;
        _loadError = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  _EarTrainingQuestion _buildQuestion() {
    switch (_mode) {
      case _EarTrainingMode.chord:
        return _buildChordQuestion();
      case _EarTrainingMode.note:
        return _buildNoteQuestion();
      case _EarTrainingMode.interval:
        return _buildIntervalQuestion();
    }
  }

  _EarTrainingQuestion _buildChordQuestion() {
    final pool = _buildChordPool(_difficulty);
    final correct = pool[_random.nextInt(pool.length)];
    final options = _buildQuizOptions(pool: pool, correct: correct, optionCount: _difficulty.optionCount);

    return _EarTrainingQuestion(
      mode: _EarTrainingMode.chord,
      prompt: 'Nghe hợp âm và chọn câu trả lời đúng',
      backendMode: 'chord',
      backendValue: correct.backendValue,
      label: correct.label,
      secondaryLabel: null,
      secondaryBackendValue: null,
      options: options,
    );
  }

  _EarTrainingQuestion _buildNoteQuestion() {
    final pool = _buildNotePool(_difficulty);
    final correct = pool[_random.nextInt(pool.length)];
    final options = _buildQuizOptions(pool: pool, correct: correct, optionCount: _difficulty.optionCount);

    return _EarTrainingQuestion(
      mode: _EarTrainingMode.note,
      prompt: 'Nghe nốt và chọn cao độ đúng',
      backendMode: 'note',
      backendValue: correct.backendValue,
      label: correct.label,
      secondaryLabel: null,
      secondaryBackendValue: null,
      options: options,
    );
  }

  _EarTrainingQuestion _buildIntervalQuestion() {
    final pool = _buildIntervalPool(_difficulty);
    final correct = pool[_random.nextInt(pool.length)];
    final options = _buildQuizOptions(pool: pool, correct: correct, optionCount: _difficulty.optionCount);

    final baseNote = _buildIntervalBaseNote();
    return _EarTrainingQuestion(
      mode: _EarTrainingMode.interval,
      prompt: 'Nghe 2 nốt và chọn khoảng cách',
      backendMode: 'interval',
      backendValue: correct.backendValue,
      label: correct.label,
      secondaryLabel: baseNote,
      secondaryBackendValue: baseNote,
      options: options,
    );
  }

  List<_EarTrainingOption> _buildQuizOptions({
    required List<_EarTrainingOption> pool,
    required _EarTrainingOption correct,
    required int optionCount,
  }) {
    final distractors = pool
        .where((option) => option.backendValue != correct.backendValue)
        .toList(growable: true)
      ..shuffle(_random);

    final options = <_EarTrainingOption>[correct, ...distractors.take(optionCount - 1)]
      ..shuffle(_random);
    return options;
  }

  String _buildIntervalBaseNote() {
    const roots = ['C4', 'D4', 'E4', 'F4', 'G4', 'A4'];
    return roots[_random.nextInt(roots.length)];
  }

  List<_EarTrainingOption> _buildChordPool(_EarTrainingDifficulty difficulty) {
    final common = <_EarTrainingOption>[
      _EarTrainingOption(label: 'C Major', backendValue: 'C:maj'),
      _EarTrainingOption(label: 'G Major', backendValue: 'G:maj'),
      _EarTrainingOption(label: 'D Major', backendValue: 'D:maj'),
      _EarTrainingOption(label: 'A Minor', backendValue: 'A:min'),
      _EarTrainingOption(label: 'E Minor', backendValue: 'E:min'),
      _EarTrainingOption(label: 'F Major', backendValue: 'F:maj'),
    ];

    final extended = <_EarTrainingOption>[
      ...common,
      _EarTrainingOption(label: 'B Minor', backendValue: 'B:min'),
      _EarTrainingOption(label: 'C Major 7', backendValue: 'C:maj7'),
      _EarTrainingOption(label: 'A Minor 7', backendValue: 'A:min7'),
      _EarTrainingOption(label: 'D7', backendValue: 'D:7'),
      _EarTrainingOption(label: 'E7', backendValue: 'E:7'),
      _EarTrainingOption(label: 'G Major 7', backendValue: 'G:maj7'),
      _EarTrainingOption(label: 'F# Diminished', backendValue: 'F#:dim'),
      _EarTrainingOption(label: 'Bb Suspended 4', backendValue: 'Bb:sus4'),
    ];

    final hard = <_EarTrainingOption>[
      ...extended,
      _EarTrainingOption(label: 'C Diminished', backendValue: 'C:dim'),
      _EarTrainingOption(label: 'D Augmented', backendValue: 'D:aug'),
      _EarTrainingOption(label: 'E Suspended 2', backendValue: 'E:sus2'),
      _EarTrainingOption(label: 'A Suspended 4', backendValue: 'A:sus4'),
    ];

    switch (difficulty) {
      case _EarTrainingDifficulty.easy:
        return common;
      case _EarTrainingDifficulty.normal:
        return extended;
      case _EarTrainingDifficulty.hard:
        return hard;
    }
  }

  List<_EarTrainingOption> _buildNotePool(_EarTrainingDifficulty difficulty) {
    final easy = <_EarTrainingOption>[
      _EarTrainingOption(label: 'C4', backendValue: 'C4'),
      _EarTrainingOption(label: 'D4', backendValue: 'D4'),
      _EarTrainingOption(label: 'E4', backendValue: 'E4'),
      _EarTrainingOption(label: 'F4', backendValue: 'F4'),
      _EarTrainingOption(label: 'G4', backendValue: 'G4'),
      _EarTrainingOption(label: 'A4', backendValue: 'A4'),
      _EarTrainingOption(label: 'B4', backendValue: 'B4'),
    ];

    final normal = <_EarTrainingOption>[
      ...easy,
      _EarTrainingOption(label: 'C#4', backendValue: 'C#4'),
      _EarTrainingOption(label: 'D#4', backendValue: 'D#4'),
      _EarTrainingOption(label: 'F#4', backendValue: 'F#4'),
      _EarTrainingOption(label: 'G#4', backendValue: 'G#4'),
      _EarTrainingOption(label: 'A#4', backendValue: 'A#4'),
      _EarTrainingOption(label: 'C5', backendValue: 'C5'),
    ];

    final hard = <_EarTrainingOption>[
      ...normal,
      _EarTrainingOption(label: 'D5', backendValue: 'D5'),
      _EarTrainingOption(label: 'E5', backendValue: 'E5'),
      _EarTrainingOption(label: 'F5', backendValue: 'F5'),
      _EarTrainingOption(label: 'G5', backendValue: 'G5'),
      _EarTrainingOption(label: 'A5', backendValue: 'A5'),
      _EarTrainingOption(label: 'B5', backendValue: 'B5'),
    ];

    switch (difficulty) {
      case _EarTrainingDifficulty.easy:
        return easy;
      case _EarTrainingDifficulty.normal:
        return normal;
      case _EarTrainingDifficulty.hard:
        return hard;
    }
  }

  List<_EarTrainingOption> _buildIntervalPool(_EarTrainingDifficulty difficulty) {
    final easy = <_EarTrainingOption>[
      _EarTrainingOption(label: 'Minor 2nd', backendValue: 'm2'),
      _EarTrainingOption(label: 'Major 2nd', backendValue: '2'),
      _EarTrainingOption(label: 'Minor 3rd', backendValue: 'm3'),
      _EarTrainingOption(label: 'Major 3rd', backendValue: '3'),
      _EarTrainingOption(label: 'Perfect 4th', backendValue: '4'),
      _EarTrainingOption(label: 'Perfect 5th', backendValue: '5'),
    ];

    final normal = <_EarTrainingOption>[
      ...easy,
      _EarTrainingOption(label: 'Minor 6th', backendValue: 'm6'),
      _EarTrainingOption(label: 'Major 6th', backendValue: '6'),
      _EarTrainingOption(label: 'Minor 7th', backendValue: 'm7'),
      _EarTrainingOption(label: 'Major 7th', backendValue: '7'),
    ];

    final hard = <_EarTrainingOption>[
      ...normal,
      _EarTrainingOption(label: 'Perfect Octave', backendValue: '8'),
      _EarTrainingOption(label: 'Descending Major 3rd', backendValue: '3-desc'),
      _EarTrainingOption(label: 'Descending Perfect 5th', backendValue: '5-desc'),
    ];

    switch (difficulty) {
      case _EarTrainingDifficulty.easy:
        return easy;
      case _EarTrainingDifficulty.normal:
        return normal;
      case _EarTrainingDifficulty.hard:
        return hard;
    }
  }

  Future<void> _playCurrentQuestion() async {
    if (_isLoadingQuestion || _question == null || _audioBytes == null) {
      return;
    }

    try {
      await _player.seek(Duration.zero);
      await _player.play();
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loadError = 'Không phát được âm thanh. Vui lòng thử lại.';
      });
    }
  }

  Future<void> _handleOptionTap(_EarTrainingOption option) async {
    if (_isLoadingQuestion || _isAnswered || _question == null) {
      return;
    }

    final isCorrect = option.backendValue == _question!.backendValue;
    setState(() {
      _selectedOption = option.backendValue;
      _isAnswered = true;
      _feedbackIsCorrect = isCorrect;
      _feedbackMessage = isCorrect
          ? 'Chính xác! +10 điểm'
          : 'Chưa đúng. Đáp án đúng là ${_question!.label}';
      if (isCorrect) {
        _score += 10;
        _streak += 1;
        _correctCount += 1;
        if (_streak > _bestStreak) {
          _bestStreak = _streak;
        }
      } else {
        _streak = 0;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_hasFinishedSession) {
      return;
    }

    if (_currentQuestionIndex >= _totalQuestionCount) {
      setState(() {
        _hasFinishedSession = true;
      });
      return;
    }

    setState(() {
      _currentQuestionIndex += 1;
    });
    await _prepareQuestion(autoPlay: false);
  }

  void _restartSession() {
    setState(() {
      _currentQuestionIndex = 1;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _correctCount = 0;
      _hasFinishedSession = false;
    });
    unawaited(_prepareQuestion(autoPlay: false));
  }

  void _changeMode(_EarTrainingMode mode) {
    if (_mode == mode) {
      return;
    }
    setState(() {
      _mode = mode;
      _currentQuestionIndex = 1;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _correctCount = 0;
      _hasFinishedSession = false;
    });
    unawaited(_prepareQuestion(autoPlay: false));
  }

  void _changeDifficulty(_EarTrainingDifficulty difficulty) {
    if (_difficulty == difficulty) {
      return;
    }
    setState(() {
      _difficulty = difficulty;
      _currentQuestionIndex = 1;
      _score = 0;
      _streak = 0;
      _bestStreak = 0;
      _correctCount = 0;
      _hasFinishedSession = false;
    });
    unawaited(_prepareQuestion(autoPlay: false));
  }

  int get _totalQuestionCount => 10;

  @override
  Widget build(BuildContext context) {
    final question = _question;
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTopBar(context),
              const SizedBox(height: 20),
              _buildSessionHeader(),
              const SizedBox(height: 18),
              _buildModeSelector(),
              const SizedBox(height: 14),
              _buildDifficultySelector(),
              const SizedBox(height: 24),
              if (_hasFinishedSession)
                _buildSummaryCard()
              else ...[
                _buildListeningCard(question),
                const SizedBox(height: 18),
                _buildPromptCard(question),
                const SizedBox(height: 18),
                _buildOptionsGrid(question),
                const SizedBox(height: 18),
                _buildControlBar(),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 16,
                height: 16,
                child: _SafeSvgAsset('assets/icons/guitar_ear_training_back.svg'),
              ),
            ),
            const SizedBox(width: 16),
            Text(
              'Cảm âm',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.9,
                height: 28 / 18,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: _restartSession,
          behavior: HitTestBehavior.opaque,
          child: SizedBox(
            width: 20.1,
            height: 20,
            child: _SafeSvgAsset('assets/icons/guitar_ear_training_more.svg'),
          ),
        ),
      ],
    );
  }

  Widget _buildSessionHeader() {
    final progress = _currentQuestionIndex / _totalQuestionCount;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Bài ${_currentQuestionIndex.toString().padLeft(2, '0')}/$_totalQuestionCount',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _SessionBadge(label: _mode.displayLabel),
              const SizedBox(width: 8),
              _SessionBadge(label: _difficulty.displayLabel),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 10,
              value: progress,
              backgroundColor: const Color(0xFF2C2C2C),
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFF923E)),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _MiniStatCard(label: 'Điểm', value: '$_score')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStatCard(label: 'Chuỗi đúng', value: '$_streak')),
              const SizedBox(width: 10),
              Expanded(child: _MiniStatCard(label: 'Đúng', value: '$_correctCount')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      children: [
        Expanded(
          child: _SegmentChip(
            label: 'Hợp âm',
            isSelected: _mode == _EarTrainingMode.chord,
            onTap: () => _changeMode(_EarTrainingMode.chord),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentChip(
            label: 'Nốt',
            isSelected: _mode == _EarTrainingMode.note,
            onTap: () => _changeMode(_EarTrainingMode.note),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentChip(
            label: 'Khoảng cách',
            isSelected: _mode == _EarTrainingMode.interval,
            onTap: () => _changeMode(_EarTrainingMode.interval),
          ),
        ),
      ],
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: [
        Expanded(
          child: _SegmentChip(
            label: 'Easy',
            isSelected: _difficulty == _EarTrainingDifficulty.easy,
            onTap: () => _changeDifficulty(_EarTrainingDifficulty.easy),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentChip(
            label: 'Normal',
            isSelected: _difficulty == _EarTrainingDifficulty.normal,
            onTap: () => _changeDifficulty(_EarTrainingDifficulty.normal),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SegmentChip(
            label: 'Hard',
            isSelected: _difficulty == _EarTrainingDifficulty.hard,
            onTap: () => _changeDifficulty(_EarTrainingDifficulty.hard),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningCard(_EarTrainingQuestion? question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF20201F),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 242,
                  height: 242,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color.fromRGBO(255, 146, 62, 0.1),
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(245, 124, 0, 0.15),
                        blurRadius: 24,
                        spreadRadius: 6,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _playCurrentQuestion,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      color: const Color(0xFF20201F),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _isPlaying
                            ? const Color.fromRGBO(255, 146, 62, 0.55)
                            : const Color.fromRGBO(255, 146, 62, 0.2),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _isPlaying
                              ? const Color.fromRGBO(255, 146, 62, 0.28)
                              : const Color.fromRGBO(245, 124, 0, 0.16),
                          blurRadius: _isPlaying ? 72 : 50,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: _isLoadingQuestion
                        ? const SizedBox(
                            width: 48,
                            height: 48,
                            child: CircularProgressIndicator(
                              strokeWidth: 3,
                              valueColor: AlwaysStoppedAnimation(Color(0xFFFF923E)),
                            ),
                          )
                        : AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            child: _isPlaying
                                ? SizedBox(
                                    key: const ValueKey('playing'),
                                    width: 96,
                                    height: 54,
                                    child: Image.asset(
                                      'assets/images/guitar_ear_training_sound_pressed.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : SizedBox(
                                    key: const ValueKey('idle'),
                                    width: 54,
                                    height: 52.5,
                                    child: _SafeSvgAsset('assets/icons/guitar_ear_training_listen.svg'),
                                  ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _isPlaying ? 'Đang phát âm thanh' : 'Nhấn để phát lại',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: const Color(0xFFFF923E),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question?.prompt ?? 'Đang tạo câu hỏi...',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.65,
              height: 1.15,
            ),
          ),
          if (question != null && question.secondaryLabel != null) ...[
            const SizedBox(height: 8),
            Text(
              'Âm gốc: ${question.secondaryLabel}',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 13,
              ),
            ),
          ],
          if (_loadError != null) ...[
            const SizedBox(height: 12),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: const Color(0xFFFF8A80),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPromptCard(_EarTrainingQuestion? question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gợi ý',
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question == null
                ? 'Chờ câu hỏi mới'
                : 'Chọn đáp án chính xác sau khi nghe âm thanh. Nếu cần, hãy nhấn lại nút phát để nghe lại.',
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 14,
              height: 1.55,
            ),
          ),
          if (_feedbackMessage != null) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _feedbackIsCorrect == true
                    ? const Color.fromRGBO(57, 179, 96, 0.16)
                    : const Color.fromRGBO(255, 90, 90, 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: _feedbackIsCorrect == true
                      ? const Color.fromRGBO(57, 179, 96, 0.32)
                      : const Color.fromRGBO(255, 90, 90, 0.24),
                ),
              ),
              child: Text(
                _feedbackMessage!,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionsGrid(_EarTrainingQuestion? question) {
    if (question == null) {
      return const SizedBox.shrink();
    }

    final options = question.options;
    final crossAxisCount = options.length <= 4 ? 2 : 3;
    return GridView.builder(
      itemCount: options.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: options.length <= 4 ? 2.0 : 1.75,
      ),
      itemBuilder: (context, index) {
        final option = options[index];
        final isSelected = _selectedOption == option.backendValue;
        final isCorrect = question.backendValue == option.backendValue;
        final showResult = _isAnswered;
        return GestureDetector(
          onTap: () => _handleOptionTap(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            decoration: BoxDecoration(
              color: showResult && isCorrect
                  ? const Color.fromRGBO(57, 179, 96, 0.18)
                  : showResult && isSelected && !isCorrect
                      ? const Color.fromRGBO(255, 90, 90, 0.14)
                      : const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: showResult && isCorrect
                    ? const Color.fromRGBO(57, 179, 96, 0.4)
                    : showResult && isSelected && !isCorrect
                        ? const Color.fromRGBO(255, 90, 90, 0.35)
                        : const Color.fromRGBO(255, 255, 255, 0.06),
              ),
            ),
            padding: const EdgeInsets.all(14),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  option.label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (showResult && isCorrect) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Đáp án đúng',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFF7CFFAA),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlBar() {
    return Row(
      children: [
        Expanded(
          child: _PrimaryActionButton(
            onTap: _isLoadingQuestion ? () {} : _playCurrentQuestion,
            label: _isPlaying ? 'Đang phát' : 'Phát lại',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _PrimaryActionButton(
            onTap: _isAnswered ? _nextQuestion : () {},
            label: _isAnswered
                ? (_currentQuestionIndex >= _totalQuestionCount ? 'Kết thúc' : 'Câu tiếp theo')
                : 'Chọn đáp án',
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    final accuracy = _totalQuestionCount == 0
        ? 0.0
        : (_correctCount / _totalQuestionCount) * 100;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Kết quả phiên luyện',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Bạn đã hoàn thành $_totalQuestionCount câu hỏi trong chế độ ${_mode.displayLabel.toLowerCase()}.',
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 13,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: _SummaryMetric(title: 'Điểm', value: '$_score')),
              const SizedBox(width: 10),
              Expanded(child: _SummaryMetric(title: 'Đúng', value: '$_correctCount')),
              const SizedBox(width: 10),
              Expanded(child: _SummaryMetric(title: 'Accuracy', value: '${accuracy.toStringAsFixed(0)}%')),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _SummaryMetric(title: 'Best streak', value: '$_bestStreak')),
              const SizedBox(width: 10),
              Expanded(child: _SummaryMetric(title: 'Chế độ', value: _mode.displayLabel)),
            ],
          ),
          const SizedBox(height: 18),
          _PrimaryActionButton(
            onTap: _restartSession,
            label: 'Chơi lại',
          ),
        ],
      ),
    );
  }
}

class _EarTrainingQuestion {
  const _EarTrainingQuestion({
    required this.mode,
    required this.prompt,
    required this.backendMode,
    required this.backendValue,
    required this.label,
    required this.secondaryLabel,
    required this.secondaryBackendValue,
    required this.options,
  });

  final _EarTrainingMode mode;
  final String prompt;
  final String backendMode;
  final String backendValue;
  final String label;
  final String? secondaryLabel;
  final String? secondaryBackendValue;
  final List<_EarTrainingOption> options;
}

class _EarTrainingOption {
  const _EarTrainingOption({
    required this.label,
    required this.backendValue,
  });

  final String label;
  final String backendValue;
}

extension _EarTrainingModeLabel on _EarTrainingMode {
  String get displayLabel {
    switch (this) {
      case _EarTrainingMode.chord:
        return 'Hợp âm';
      case _EarTrainingMode.note:
        return 'Nốt';
      case _EarTrainingMode.interval:
        return 'Khoảng cách';
    }
  }
}

extension _EarTrainingDifficultyLabel on _EarTrainingDifficulty {
  String get displayLabel {
    switch (this) {
      case _EarTrainingDifficulty.easy:
        return 'Easy';
      case _EarTrainingDifficulty.normal:
        return 'Normal';
      case _EarTrainingDifficulty.hard:
        return 'Hard';
    }
  }

  int get optionCount {
    switch (this) {
      case _EarTrainingDifficulty.easy:
        return 4;
      case _EarTrainingDifficulty.normal:
        return 6;
      case _EarTrainingDifficulty.hard:
        return 8;
    }
  }

  int get durationMs {
    switch (this) {
      case _EarTrainingDifficulty.easy:
        return 1600;
      case _EarTrainingDifficulty.normal:
        return 1400;
      case _EarTrainingDifficulty.hard:
        return 1200;
    }
  }

  double get gain {
    switch (this) {
      case _EarTrainingDifficulty.easy:
        return 0.24;
      case _EarTrainingDifficulty.normal:
        return 0.21;
      case _EarTrainingDifficulty.hard:
        return 0.19;
    }
  }
}

class _SessionBadge extends StatelessWidget {
  const _SessionBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  const _MiniStatCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentChip extends StatelessWidget {
  const _SegmentChip({required this.label, required this.isSelected, required this.onTap});

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFF923E) : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? const Color(0xFFFF923E) : const Color.fromRGBO(255, 255, 255, 0.05),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            color: isSelected ? const Color(0xFF4D2300) : Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _PrimaryActionButton extends StatelessWidget {
  const _PrimaryActionButton({required this.onTap, required this.label});

  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFFFF923E), Color(0xFFF97F06)],
          ),
          borderRadius: BorderRadius.circular(9999),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(245, 124, 0, 0.25),
              blurRadius: 28,
              offset: Offset(0, 10),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF4D2300),
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _SafeSvgAsset extends StatelessWidget {
  const _SafeSvgAsset(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => const Center(
        child: Icon(Icons.image_not_supported, size: 16, color: Color(0xFF717171)),
      ),
    );
  }
}
