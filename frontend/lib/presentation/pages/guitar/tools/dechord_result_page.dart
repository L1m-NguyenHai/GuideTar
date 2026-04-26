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
  VideoPlayerController? _videoController;
  YoutubePlayerController? _youtubeController;
  Timer? _positionTicker;
  Timer? _youtubeInitTimeout;

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
    for (int i = 0; i < beats.length; i++) {
      final beat = beats[i];
      if (beat == null) continue;
      if (beat <= currentSeconds) {
        index = i;
      } else {
        break;
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

  @override
  Widget build(BuildContext context) {
    final progress = _duration.inMilliseconds <= 0
        ? 0.0
        : (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);

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
              _ResultSummarySection(result: widget.result),
              const SizedBox(height: 14),
              _ResultChordGrid(
                result: widget.result,
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
  const _ResultSummarySection({required this.result});

  final DechordAnalyzeResult result;

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
            _buildMiniCard(title: 'MODEL', value: 'AI'),
          ],
        ),
      ],
    );
  }
}

class _GridCell {
  const _GridCell({
    required this.label,
    required this.index,
    required this.isFilled,
  });

  final String label;
  final int index;
  final bool isFilled;
}

class _ResultChordGrid extends StatefulWidget {
  const _ResultChordGrid({
    required this.result,
    required this.activeIndex,
  });

  final DechordAnalyzeResult result;
  final int activeIndex;

  @override
  State<_ResultChordGrid> createState() => _ResultChordGridState();
}

class _ResultChordGridState extends State<_ResultChordGrid> {
  static const int _columnsPerRow = 4;
  static const double _rowHeight = 52;
  static const double _rowGap = 6;

  final ScrollController _scrollController = ScrollController();
  int _lastFollowedRow = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncScrollWithActive(force: true));
  }

  @override
  void didUpdateWidget(covariant _ResultChordGrid oldWidget) {
    super.didUpdateWidget(oldWidget);
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
    if (!_scrollController.hasClients) return;

    final rowIndex = widget.activeIndex ~/ _columnsPerRow;
    if (!force && rowIndex == _lastFollowedRow) return;

    final position = _scrollController.position;
    final rowSpan = _rowHeight + _rowGap;
    final viewportHeight = position.viewportDimension;

    if (viewportHeight <= 0) return;

    final rowTop = rowIndex * rowSpan;
    final rowBottom = rowTop + _rowHeight;
    final visibleTop = position.pixels;
    final visibleBottom = visibleTop + viewportHeight;

    // Keep active row in a comfortable band instead of hard-centering to avoid big jumps.
    final safeTop = visibleTop + (viewportHeight * 0.18);
    final safeBottom = visibleBottom - (viewportHeight * 0.30);
    final rowOutsideBand = rowTop < safeTop || rowBottom > safeBottom;

    if (force || rowOutsideBand) {
      final targetOffset = rowTop - (viewportHeight * 0.24);
      final clamped = targetOffset.clamp(0.0, position.maxScrollExtent);

      _scrollController.animateTo(
        clamped,
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
      );
    }

    _lastFollowedRow = rowIndex;
  }

  @override
  Widget build(BuildContext context) {
    final gridCells = _buildGridCells(widget.result.displayChords);

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
            'Lưới hợp âm (${widget.result.displayChords.length} beat)',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 390,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  for (int row = 0; row < gridCells.length; row += _columnsPerRow) ...[
                    Row(
                      children: [
                        for (int col = 0; col < _columnsPerRow; col++) ...[
                          Expanded(
                            child: _ChordGridCell(
                              label: gridCells[row + col].label,
                              isFilled: gridCells[row + col].isFilled,
                              isActive: gridCells[row + col].index == widget.activeIndex,
                              isMeasureStart: col == 0,
                            ),
                          ),
                          if (col != _columnsPerRow - 1) const SizedBox(width: 4),
                        ],
                      ],
                    ),
                    if (row + _columnsPerRow < gridCells.length) const SizedBox(height: _rowGap),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<_GridCell> _buildGridCells(List<String> labels) {
    final cells = <_GridCell>[];
    for (int i = 0; i < labels.length; i++) {
      final label = labels[i];
      cells.add(_GridCell(label: label, index: i, isFilled: label.trim().isNotEmpty));
    }

    while (cells.isEmpty || cells.length % _columnsPerRow != 0) {
      cells.add(_GridCell(label: '', index: cells.length, isFilled: false));
    }

    return cells;
  }
}

class _ChordGridCell extends StatelessWidget {
  const _ChordGridCell({
    required this.label,
    required this.isFilled,
    required this.isActive,
    required this.isMeasureStart,
  });

  final String label;
  final bool isFilled;
  final bool isActive;
  final bool isMeasureStart;

  @override
  Widget build(BuildContext context) {
    final bgColor = isActive
        ? const Color(0xFF2F5FDD)
        : (isFilled ? const Color(0xFF1D1D1D) : const Color(0xFF2A2A2A));

    return Container(
      height: 46,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          left: BorderSide(
            width: isMeasureStart ? 3 : 1,
            color: isMeasureStart ? const Color(0xFFFF923E) : const Color(0xFF4A4A4A),
          ),
          right: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
          top: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
          bottom: const BorderSide(width: 1, color: Color(0xFF4A4A4A)),
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Align(
        alignment: Alignment.topLeft,
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
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

    final output = <String>[];
    String previous = '';

    for (final item in labels) {
      final next = normalize(item);
      if (next.isEmpty) {
        output.add('');
        continue;
      }

      if (next == previous) {
        output.add('');
      } else {
        output.add(next);
        previous = next;
      }
    }

    return output;
  }
}
