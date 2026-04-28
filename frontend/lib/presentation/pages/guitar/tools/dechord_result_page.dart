import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class DeChordResultPage extends StatefulWidget {
  const DeChordResultPage({
    super.key,
    required this.result,
    required this.fileName,
    this.filePath,
    this.fileBytes,
    this.isYoutubeSource = false,
    this.youtubeUrl,
    this.youtubeThumbnailUrl,
  });

  final DechordAnalyzeResult result;
  final String? fileName;
  final String? filePath;
  final Uint8List? fileBytes;
  final bool isYoutubeSource;
  final String? youtubeUrl;
  final String? youtubeThumbnailUrl;

  @override
  State<DeChordResultPage> createState() => _DeChordResultPageState();
}

class _DeChordResultPageState extends State<DeChordResultPage> {
  static const int _capoMin = 0;
  static const int _capoMax = 7;
  static const List<String> _sharpNotes = ['C', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B'];
  static const List<String> _flatNotes = ['C', 'Db', 'D', 'Eb', 'E', 'F', 'Gb', 'G', 'Ab', 'A', 'Bb', 'B'];

  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  Timer? _positionTicker;
  Timer? _youtubeInitTimeout;

  int _capo = 0;
  bool _isAudioReady = false;
  bool _isPlaying = false;
  bool _isPreparingAudio = true;
  bool _youtubeReady = false;
  String? _audioError;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _activeBeatIndex = 0;

  @override
  void initState() {
    super.initState();
    if (widget.isYoutubeSource) {
      _prepareYoutubePlayer();
    } else {
      _prepareAudio();
    }
  }

  @override
  void dispose() {
    _positionTicker?.cancel();
    _youtubeInitTimeout?.cancel();
    _videoController?.removeListener(_onVideoStateChanged);
    _videoController?.dispose();
    _youtubeController?.removeListener(_onYoutubeStateChanged);
    _youtubeController?.dispose();
    super.dispose();
  }

  void _prepareYoutubePlayer() {
    try {
      final sourceUrl = widget.youtubeUrl;
      final videoId = sourceUrl == null ? null : YoutubePlayer.convertUrlToId(sourceUrl);
      if (videoId == null || videoId.isEmpty) {
        throw Exception('Không đọc được video id từ link YouTube.');
      }

      final controller = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: false,
          forceHD: false,
        ),
      );

      _youtubeController = controller;
      controller.addListener(_onYoutubeStateChanged);

      _youtubeInitTimeout?.cancel();
      _youtubeInitTimeout = Timer(const Duration(seconds: 12), () {
        if (!mounted || _youtubeReady) return;
        setState(() {
          _isPreparingAudio = false;
          _isAudioReady = false;
          _audioError = 'YouTube player tải quá lâu trên emulator. Bạn có thể mở video ngoài app.';
        });
      });

      _positionTicker?.cancel();
      _positionTicker = Timer.periodic(const Duration(milliseconds: 220), (_) {
        _onYoutubeStateChanged();
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPreparingAudio = false;
        _audioError = 'Không mở được player YouTube: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  Future<void> _prepareAudio() async {
    try {
      String? path = widget.filePath;
      if ((path == null || path.isEmpty) && widget.fileBytes != null) {
        final tempDir = await getTemporaryDirectory();
        final targetFile = File('${tempDir.path}/dechord_selected_audio.mp3');
        await targetFile.writeAsBytes(widget.fileBytes!, flush: true);
        path = targetFile.path;
      }

      if (path == null || path.isEmpty) {
        throw Exception('Không tìm thấy dữ liệu audio để phát.');
      }

      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      await controller.setLooping(false);
      controller.addListener(_onVideoStateChanged);

      _videoController = controller;
      _positionTicker?.cancel();
      _positionTicker = Timer.periodic(const Duration(milliseconds: 200), (_) {
        _onVideoStateChanged();
      });

      if (!mounted) return;
      setState(() {
        _isAudioReady = true;
        _isPreparingAudio = false;
        _duration = controller.value.duration;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isPreparingAudio = false;
        _audioError = 'Không chuẩn bị được audio: ${error.toString().replaceFirst('Exception: ', '')}';
      });
    }
  }

  void _onVideoStateChanged() {
    final controller = _videoController;
    if (!mounted || controller == null || !controller.value.isInitialized) return;

    final position = controller.value.position;
    final duration = controller.value.duration;
    final playing = controller.value.isPlaying;

    setState(() {
      _position = position;
      _duration = duration;
      _isPlaying = playing;
      _activeBeatIndex = _findBeatIndexByTime(position.inMilliseconds / 1000);
    });
  }

  void _onYoutubeStateChanged() {
    final controller = _youtubeController;
    if (!mounted || controller == null) return;

    final position = controller.value.position;
    final duration = controller.metadata.duration;
    final isPlaying = controller.value.isPlaying;
    final isReady = controller.value.isReady;
    final hasError = controller.value.hasError;

    setState(() {
      if (isReady && !_youtubeReady) {
        _youtubeReady = true;
        _isAudioReady = true;
        _isPreparingAudio = false;
        _audioError = null;
        _youtubeInitTimeout?.cancel();
      }

      if (hasError) {
        _isPreparingAudio = false;
        _isAudioReady = false;
        _audioError = 'YouTube player không phát được video này trong app.';
      }

      _position = position;
      _duration = duration;
      _isPlaying = isPlaying;
      _activeBeatIndex = _findBeatIndexByTime(position.inMilliseconds / 1000);
    });
  }

  int _findBeatIndexByTime(double currentSeconds) {
    final beats = widget.result.beats;
    if (beats.isEmpty) return 0;

    int index = 0;
    double? closestPastBeat;

    for (int i = 0; i < beats.length; i++) {
      final beat = beats[i];
      if (beat == null || beat > currentSeconds) continue;

      if (closestPastBeat == null || beat >= closestPastBeat) {
        closestPastBeat = beat;
        index = i;
      }
    }

    final maxIndex = widget.result.displayChords.isEmpty ? 0 : widget.result.displayChords.length - 1;
    return index.clamp(0, maxIndex);
  }

  Future<void> _togglePlayPause() async {
    if (widget.isYoutubeSource) {
      final controller = _youtubeController;
      if (!_isAudioReady || controller == null || !_youtubeReady) return;

      if (_isPlaying) {
        controller.pause();
        return;
      }

      if (_position >= _duration && _duration > Duration.zero) {
        controller.seekTo(Duration.zero);
      }

      controller.play();
      return;
    }

    final controller = _videoController;
    if (!_isAudioReady || controller == null || !controller.value.isInitialized) return;

    if (_isPlaying) {
      await controller.pause();
      return;
    }

    if (_position >= _duration && _duration > Duration.zero) {
      await controller.seekTo(Duration.zero);
    }

    await controller.play();
  }

  Future<void> _openYoutubeExternally() async {
    final sourceUrl = widget.youtubeUrl;
    if (sourceUrl == null || sourceUrl.isEmpty) return;
    final uri = Uri.tryParse(sourceUrl);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _seekTo(double ratio) async {
    if (widget.isYoutubeSource) {
      final controller = _youtubeController;
      if (!_isAudioReady || controller == null || _duration <= Duration.zero) return;

      final clamped = ratio.clamp(0.0, 1.0);
      final target = Duration(milliseconds: (_duration.inMilliseconds * clamped).round());
      controller.seekTo(target);
      return;
    }

    final controller = _videoController;
    if (!_isAudioReady || controller == null || !controller.value.isInitialized || _duration <= Duration.zero) {
      return;
    }

    final clamped = ratio.clamp(0.0, 1.0);
    final target = Duration(milliseconds: (_duration.inMilliseconds * clamped).round());
    await controller.seekTo(target);
  }

  String _formatDuration(Duration value) {
    final totalSeconds = value.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString();
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _setCapo(int value) {
    final next = value.clamp(_capoMin, _capoMax);
    if (next == _capo) return;
    setState(() {
      _capo = next;
    });
  }

  List<String> _transposeChordsForCapo(List<String> labels, int capo) {
    if (capo <= 0) return labels;
    final semitoneShift = -capo;
    return labels
        .map((label) => _transposeChordLabel(label, semitoneShift))
        .toList(growable: false);
  }

  String _transposeChordLabel(String label, int semitones) {
    final trimmed = label.trim();
    if (trimmed.isEmpty || trimmed == 'N/C') return label;

    final parts = trimmed.split('/');
    final transposedParts = parts
        .map((part) => _transposeChordPart(part, semitones))
        .toList(growable: false);
    return transposedParts.join('/');
  }

  String _transposeChordPart(String part, int semitones) {
    final token = part.trim();
    if (token.isEmpty) return part;

    final root = _readRoot(token);
    if (root == null) return part;

    final preferSharps = root.contains('#');
    final index = _noteToIndex(root);
    if (index == null) return part;

    final nextIndex = (index + semitones) % 12;
    final safeIndex = nextIndex < 0 ? nextIndex + 12 : nextIndex;
    final nextRoot = preferSharps ? _sharpNotes[safeIndex] : _flatNotes[safeIndex];
    return '$nextRoot${token.substring(root.length)}';
  }

  String? _readRoot(String token) {
    if (token.isEmpty) return null;
    final first = token[0].toUpperCase();
    if (!'ABCDEFG'.contains(first)) return null;
    if (token.length >= 2) {
      final second = token[1];
      if (second == '#' || second == 'b') {
        return '$first$second';
      }
    }
    return first;
  }

  int? _noteToIndex(String note) {
    final idxSharp = _sharpNotes.indexOf(note);
    if (idxSharp != -1) return idxSharp;
    final idxFlat = _flatNotes.indexOf(note);
    if (idxFlat != -1) return idxFlat;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    final displayChords = _transposeChordsForCapo(widget.result.displayChords, _capo);

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    child: const SizedBox(
                      width: 24,
                      height: 24,
                      child: Icon(
                        Icons.arrow_back_ios_new_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Kết quả AI DeChord',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.fileName ?? 'Bài hát đã phân tích',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  color: const Color(0xFFADAAAA),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              if (widget.isYoutubeSource && _youtubeController != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                    showVideoProgressIndicator: true,
                    progressIndicatorColor: const Color(0xFFFF923E),
                    progressColors: const ProgressBarColors(
                      playedColor: Color(0xFFFF923E),
                      handleColor: Color(0xFFFF923E),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (_audioError != null) ...[
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: _openYoutubeExternally,
                      icon: const Icon(Icons.open_in_new_rounded, size: 16, color: Color(0xFFFF923E)),
                      label: Text(
                        'Mở YouTube ngoài app',
                        style: GoogleFonts.manrope(color: const Color(0xFFFF923E), fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
              _AudioSyncPanel(
                title: widget.isYoutubeSource ? 'Đồng bộ hợp âm theo video YouTube' : 'Đồng bộ hợp âm theo audio',
                isReady: _isAudioReady,
                isPreparing: _isPreparingAudio,
                isPlaying: _isPlaying,
                error: _audioError,
                progress: progress,
                currentText: _formatDuration(_position),
                totalText: _formatDuration(_duration),
                onPlayPause: _togglePlayPause,
                onSeek: _seekTo,
              ),
              const SizedBox(height: 18),
              _ResultSummarySection(result: widget.result, capo: _capo),
              const SizedBox(height: 12),
              _CapoControl(
                capo: _capo,
                minCapo: _capoMin,
                maxCapo: _capoMax,
                onDecrease: () => _setCapo(_capo - 1),
                onIncrease: () => _setCapo(_capo + 1),
              ),
              const SizedBox(height: 14),
              _ResultChordTimeline(
                result: widget.result,
                displayChords: displayChords,
                activeIndex: _activeBeatIndex,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AudioSyncPanel extends StatelessWidget {
  const _AudioSyncPanel({
    required this.title,
    required this.isReady,
    required this.isPreparing,
    required this.isPlaying,
    required this.error,
    required this.progress,
    required this.currentText,
    required this.totalText,
    required this.onPlayPause,
    required this.onSeek,
  });

  final String title;
  final bool isReady;
  final bool isPreparing;
  final bool isPlaying;
  final String? error;
  final double progress;
  final String currentText;
  final String totalText;
  final VoidCallback onPlayPause;
  final ValueChanged<double> onSeek;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.07)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            error ?? (isPreparing ? 'Đang chuẩn bị audio...' : 'Play audio để chạy highlight hợp âm theo beat.'),
            style: GoogleFonts.manrope(
              color: error == null ? const Color(0xFFADAAAA) : const Color(0xFFFFB885),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              GestureDetector(
                onTap: isReady ? onPlayPause : null,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isReady ? const Color(0xFFFF923E) : const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: isReady ? const Color(0xFF4D2300) : const Color(0xFF787878),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFFF923E),
                    inactiveTrackColor: const Color(0xFF3A3A3A),
                    thumbColor: const Color(0xFFFF923E),
                    overlayColor: const Color.fromRGBO(255, 146, 62, 0.18),
                  ),
                  child: Slider(
                    value: progress,
                    onChanged: isReady ? onSeek : null,
                  ),
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '$currentText / $totalText',
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResultSummarySection extends StatelessWidget {
  const _ResultSummarySection({required this.result, required this.capo});

  final DechordAnalyzeResult result;
  final int capo;

  Widget _buildMiniCard({required String title, required String value}) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF131313),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                color: const Color(0xFF8C8C8C),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _buildMiniCard(title: 'BPM', value: result.bpm.round().toString()),
            const SizedBox(width: 10),
            _buildMiniCard(title: 'BEAT', value: result.beatCount.toString()),
            const SizedBox(width: 10),
            _buildMiniCard(title: 'TIME', value: '${result.timeSignature}/4'),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _buildMiniCard(title: 'CHORD', value: result.chordCount.toString()),
            const SizedBox(width: 10),
            _buildMiniCard(title: 'RAW', value: result.rawChordCount.toString()),
            const SizedBox(width: 10),
            _buildMiniCard(title: 'CAPO', value: capo.toString()),
          ],
        ),
      ],
    );
  }
}

class _CapoControl extends StatelessWidget {
  const _CapoControl({
    required this.capo,
    required this.minCapo,
    required this.maxCapo,
    required this.onDecrease,
    required this.onIncrease,
  });

  final int capo;
  final int minCapo;
  final int maxCapo;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;

  @override
  Widget build(BuildContext context) {
    final canDecrease = capo > minCapo;
    final canIncrease = capo < maxCapo;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.07)),
      ),
      child: Row(
        children: [
          Text(
            'Capo',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '0–7',
            style: GoogleFonts.manrope(
              color: const Color(0xFF8A8A8A),
              fontSize: 12,
            ),
          ),
          const Spacer(),
          _CapoButton(
            icon: Icons.remove,
            enabled: canDecrease,
            onTap: onDecrease,
          ),
          const SizedBox(width: 10),
          Container(
            width: 44,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF1B1B1B),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.08)),
            ),
            child: Text(
              capo.toString(),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          _CapoButton(
            icon: Icons.add,
            enabled: canIncrease,
            onTap: onIncrease,
          ),
        ],
      ),
    );
  }
}

class _CapoButton extends StatelessWidget {
  const _CapoButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFFFF923E) : const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: enabled ? const Color(0xFF4D2300) : const Color(0xFF707070),
          size: 18,
        ),
      ),
    );
  }
}

class _TimelineBeatCellModel {
  const _TimelineBeatCellModel({
    required this.label,
    required this.index,
    required this.beatInMeasure,
  });

  final String label;
  final int index;
  final int beatInMeasure;

  bool get isFilled => label.trim().isNotEmpty;

  _TimelineBeatCellModel copyWith({String? label}) {
    return _TimelineBeatCellModel(
      label: label ?? this.label,
      index: index,
      beatInMeasure: beatInMeasure,
    );
  }
}

class _TimelineMeasureModel {
  const _TimelineMeasureModel({
    required this.measureNumber,
    required this.startBeatIndex,
    required this.cells,
  });

  final int measureNumber;
  final int startBeatIndex;
  final List<_TimelineBeatCellModel> cells;
}

class _ResultChordTimeline extends StatefulWidget {
  const _ResultChordTimeline({
    required this.result,
    required this.displayChords,
    required this.activeIndex,
  });

  final DechordAnalyzeResult result;
  final List<String> displayChords;
  final int activeIndex;

  @override
  State<_ResultChordTimeline> createState() => _ResultChordTimelineState();
}

class _ResultChordTimelineState extends State<_ResultChordTimeline> {
  static const double _rowExtent = 66;
  static const int _longSongThreshold = 480;

  final ScrollController _scrollController = ScrollController();
  int _lastFollowedMeasure = -1;
  late List<_TimelineMeasureModel> _measures;

  int get _beatsPerMeasure => widget.result.timeSignature <= 0 ? 4 : widget.result.timeSignature;

  bool get _compactMode => widget.displayChords.length >= _longSongThreshold;

  @override
  void initState() {
    super.initState();
    _measures = _buildMeasures(widget.displayChords, _beatsPerMeasure);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollWithActive(force: true));
  }

  @override
  void didUpdateWidget(covariant _ResultChordTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.displayChords != widget.displayChords ||
        oldWidget.result.timeSignature != widget.result.timeSignature) {
      _measures = _buildMeasures(widget.displayChords, _beatsPerMeasure);
      _lastFollowedMeasure = -1;
    }

    if (oldWidget.activeIndex != widget.activeIndex) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollWithActive());
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncScrollWithActive({bool force = false}) {
    if (!_scrollController.hasClients || _measures.isEmpty) return;

    final active = widget.activeIndex.clamp(0, widget.displayChords.isEmpty ? 0 : widget.displayChords.length - 1);
    final measureIndex = active ~/ _beatsPerMeasure;
    if (!force && measureIndex == _lastFollowedMeasure) return;

    final position = _scrollController.position;
    final viewportHeight = position.viewportDimension;
    if (viewportHeight <= 0) return;

    final rowTop = measureIndex * _rowExtent;
    final rowBottom = rowTop + _rowExtent;
    final visibleTop = position.pixels;
    final visibleBottom = visibleTop + viewportHeight;
    final safeTop = visibleTop + (viewportHeight * 0.20);
    final safeBottom = visibleBottom - (viewportHeight * 0.28);

    if (force || rowTop < safeTop || rowBottom > safeBottom) {
      final target = (rowTop - (viewportHeight * 0.22)).clamp(0.0, position.maxScrollExtent);
      _scrollController.animateTo(
        target,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
      );
    }

    _lastFollowedMeasure = measureIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Timeline hợp âm (${widget.displayChords.length} beat)',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _LegendChip(text: 'Đang chạy', color: const Color(0xFF2F5FDD)),
              _LegendChip(text: 'Beat 1', color: const Color(0xFFFF923E)),
              _LegendChip(text: 'N/C', color: const Color(0xFF3A3A3A)),
              if (_compactMode) _LegendChip(text: 'Chế độ mượt cho bài dài', color: const Color(0xFF2D2D2D)),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 406,
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _measures.length,
              itemExtent: _rowExtent,
              cacheExtent: _rowExtent * 10,
              itemBuilder: (context, index) {
                final measure = _measures[index];
                final active = widget.activeIndex.clamp(
                  0,
                  widget.displayChords.isEmpty ? 0 : widget.displayChords.length - 1,
                );
                return RepaintBoundary(
                  child: _TimelineMeasureRow(
                    measure: measure,
                    activeIndex: active,
                    compactMode: _compactMode,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<_TimelineMeasureModel> _buildMeasures(List<String> labels, int beatsPerMeasure) {
    final normalizedBeatsPerMeasure = beatsPerMeasure <= 0 ? 4 : beatsPerMeasure;
    final measures = <_TimelineMeasureModel>[];
    if (labels.isEmpty) {
      measures.add(
        _TimelineMeasureModel(
          measureNumber: 1,
          startBeatIndex: 0,
          cells: [
            for (int beat = 0; beat < normalizedBeatsPerMeasure; beat++)
              _TimelineBeatCellModel(label: '', index: beat, beatInMeasure: beat + 1),
          ],
        ),
      );
      return measures;
    }

    for (int start = 0; start < labels.length; start += normalizedBeatsPerMeasure) {
      final rawLabels = <String>[];
      for (int offset = 0; offset < normalizedBeatsPerMeasure; offset++) {
        final beatIndex = start + offset;
        rawLabels.add(beatIndex < labels.length ? labels[beatIndex] : '');
      }

      String carryChord = '';
      for (int j = start - 1; j >= 0; j--) {
        if (labels[j].trim().isNotEmpty) {
          carryChord = labels[j];
          break;
        }
      }

      final compressedLabels = _compressMeasureLabels(rawLabels, carryChord);
      final cells = <_TimelineBeatCellModel>[];
      for (int offset = 0; offset < normalizedBeatsPerMeasure; offset++) {
        final beatIndex = start + offset;
        cells.add(
          _TimelineBeatCellModel(
            label: compressedLabels[offset],
            index: beatIndex,
            beatInMeasure: offset + 1,
          ),
        );
      }

      measures.add(
        _TimelineMeasureModel(
          measureNumber: (start ~/ normalizedBeatsPerMeasure) + 1,
          startBeatIndex: start,
          cells: cells,
        ),
      );
    }

    return measures;
  }

  List<String> _compressMeasureLabels(List<String> rawLabels, String carryChord) {
    final length = rawLabels.length;
    if (length == 0) return rawLabels;

    final trimmed = rawLabels.map((label) => label.trim()).toList(growable: false);
    final compressed = List<String>.from(rawLabels);

    for (int i = 1; i < length; i++) {
      final current = trimmed[i];
      if (current.isEmpty) continue;
      final prev = trimmed[i - 1];
      if (prev.isNotEmpty && prev == current) {
        compressed[i] = '';
      }
    }

    final allSameNonEmpty = trimmed.every((label) => label.isNotEmpty) &&
        trimmed.every((label) => label == trimmed.first);
    if (allSameNonEmpty) {
      for (int i = 1; i < length; i++) {
        compressed[i] = '';
      }
      compressed[0] = rawLabels.first;
    }

    final hasAny = compressed.any((label) => label.trim().isNotEmpty);
    if (!hasAny && carryChord.trim().isNotEmpty) {
      compressed[length - 1] = carryChord;
    }

    return compressed;
  }
}

class _TimelineMeasureRow extends StatelessWidget {
  const _TimelineMeasureRow({
    required this.measure,
    required this.activeIndex,
    required this.compactMode,
  });

  final _TimelineMeasureModel measure;
  final int activeIndex;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              'Ô ${measure.measureNumber}',
              style: GoogleFonts.manrope(
                color: const Color(0xFF8A8A8A),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (int i = 0; i < measure.cells.length; i++) ...[
                  Expanded(
                    child: _TimelineBeatCell(
                      cell: measure.cells[i],
                      isActive: measure.cells[i].index == activeIndex,
                      compactMode: compactMode,
                    ),
                  ),
                  if (i != measure.cells.length - 1) const SizedBox(width: 4),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineBeatCell extends StatelessWidget {
  const _TimelineBeatCell({
    required this.cell,
    required this.isActive,
    required this.compactMode,
  });

  final _TimelineBeatCellModel cell;
  final bool isActive;
  final bool compactMode;

  @override
  Widget build(BuildContext context) {
    final trimmed = cell.label.trim();
    final isNc = trimmed == 'N/C';
    final bgColor = isActive
        ? const Color(0xFF2F5FDD)
        : (!cell.isFilled ? const Color(0xFF2A2A2A) : (isNc ? const Color(0xFF222222) : const Color(0xFF1A1A1A)));

    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: compactMode ? 4 : 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            width: cell.beatInMeasure == 1 ? 3 : 1,
            color: cell.beatInMeasure == 1 ? const Color(0xFFFF923E) : const Color(0xFF4A4A4A),
          ),
          right: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
          top: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
          bottom: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${cell.beatInMeasure}',
            style: GoogleFonts.manrope(
              color: isActive ? Colors.white : const Color(0xFF9D9D9D),
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 3),
          Expanded(
            child: Align(
              alignment: Alignment.topLeft,
              child: Text(
                trimmed,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.plusJakartaSans(
                  color: isActive
                      ? Colors.white
                      : (isNc ? const Color(0xFFB7B7B7) : (cell.isFilled ? Colors.white : const Color(0xFF7D7D7D))),
                  fontSize: compactMode ? 11 : 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B1B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.manrope(
              color: const Color(0xFFDFDFDF),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class DechordAnalyzeResult {
  DechordAnalyzeResult({
    required this.bpm,
    required this.timeSignature,
    required this.displayChords,
    required this.beatCount,
    required this.chordCount,
    required this.rawChordCount,
    required this.beats,
  });

  final double bpm;
  final int timeSignature;
  final List<String> displayChords;
  final int beatCount;
  final int chordCount;
  final int rawChordCount;
  final List<double?> beats;

  factory DechordAnalyzeResult.fromJson(Map<String, dynamic> json) {
    final beatResult = (json['beatDetectionResult'] is Map<String, dynamic>)
        ? json['beatDetectionResult'] as Map<String, dynamic>
        : <String, dynamic>{};

    final rawChords = _readStringList(json['chords']);
    final displayChords = _toDisplayChords(rawChords);
    final beats = _readNullableDoubleList(json['beats']);

    return DechordAnalyzeResult(
      bpm: _readDouble(beatResult['bpm']) ?? _readDouble(json['bpm']) ?? 0,
      timeSignature: _readInt(beatResult['time_signature']) ?? 4,
      displayChords: displayChords,
      beatCount: beats.length,
      chordCount: _readInt(json['chord_count']) ?? rawChords.length,
      rawChordCount: _readInt(json['rawChordCount']) ?? 0,
      beats: beats,
    );
  }

  static List<String> _readStringList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) => item?.toString() ?? '').toList();
  }

  static List<double?> _readNullableDoubleList(dynamic value) {
    if (value is! List) return const [];
    return value.map((item) {
      if (item == null) return null;
      if (item is num) return item.toDouble();
      if (item is String) return double.tryParse(item);
      return null;
    }).toList();
  }

  static double? _readDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static int? _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  static List<String> _toDisplayChords(List<String> labels) {
    String normalize(String chord) {
      final trimmed = chord.trim();
      if (trimmed.isEmpty) return '';
      if (trimmed == 'N' || trimmed == 'N.C.' || trimmed == 'NC' || trimmed == 'N/C') {
        return 'N/C';
      }
      return trimmed;
    }

    return labels.map(normalize).toList();
  }
}
