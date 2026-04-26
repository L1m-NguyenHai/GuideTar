import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import 'package:guidetar/presentation/pages/guitar/tools/artist_jack_page.dart';
import 'package:guidetar/presentation/pages/guitar/tools/song_gio_reviews_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SongGioChordPage extends StatefulWidget {
  const SongGioChordPage({super.key});

  @override
  State<SongGioChordPage> createState() => _SongGioChordPageState();
}

class _SongGioChordPageState extends State<SongGioChordPage> {
  static const String _amChordImageAsset = 'assets/images/am_chord_board.png';
  static const String _em7ChordImageAsset = 'assets/images/em7_chord_board.png';

  int _selectedNavIndex = 1;

  void _onNavChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
  }

  void _showAmChordBoard() {
    _showChordBoard(
      chordLabel: '[Am]',
      imageAsset: _amChordImageAsset,
    );
  }

  void _showEm7ChordBoard() {
    _showChordBoard(
      chordLabel: '[Em7]',
      imageAsset: _em7ChordImageAsset,
    );
  }

  void _showChordBoard({required String chordLabel, required String imageAsset}) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.55),
      builder: (dialogContext) {
        return Material(
          color: Colors.transparent,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Navigator.of(dialogContext).pop(),
            child: Center(
              child: GestureDetector(
                behavior: HitTestBehavior.deferToChild,
                onTap: () {},
                child: Container(
                  width: 183,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 183,
                        child: Text(
                          chordLabel,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.splineSans(
                            color: Colors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            height: 23 / 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          imageAsset,
                          width: 183,
                          height: 221,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SongHeader(),
                  SizedBox(height: 14),
                  _MetaGrid(),
                  SizedBox(height: 16),
                  _MediaCard(),
                  SizedBox(height: 16),
                  _ToolBar(),
                  SizedBox(height: 20),
                  _LyricsSection(onChordTap: _handleChordTap),
                ],
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: HomeBottomNavbar(
                  selectedIndex: _selectedNavIndex,
                  onChanged: _onNavChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleChordTap(String chord) {
    final normalized = chord.toLowerCase();
    if (normalized.contains('em7')) {
      _showEm7ChordBoard();
      return;
    }

    if (normalized.contains('am')) {
      _showAmChordBoard();
    }
  }
}

class _SongHeader extends StatelessWidget {
  const _SongHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).maybePop(),
          behavior: HitTestBehavior.translucent,
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
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Sóng gió',
                style: GoogleFonts.splineSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.6,
                  height: 32 / 24,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArtistJackPage()),
                  );
                },
                child: Text(
                  'Jack',
                  style: GoogleFonts.splineSans(
                    color: const Color(0xFFF79633),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                    height: 28 / 16,
                  ),
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SongGioReviewsPage()),
            );
          },
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF20201F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 11.7,
                  height: 11.1,
                  child: SvgPicture.asset('assets/icons/songgio_rating_star.svg'),
                ),
                const SizedBox(width: 4),
                Text(
                  '4.5',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '(386)',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 10,
                    height: 15 / 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(244, 140, 37, 0.2),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: const Color.fromRGBO(244, 140, 37, 0.3)),
          ),
          child: Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: SvgPicture.asset('assets/icons/chord_filter_icon.svg'),
            ),
          ),
        ),
      ],
    );
  }
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _MetaCard(
            label: 'Tone',
            value: '[Am]',
            valueColor: Color(0xFFFF923E),
            iconAsset: 'assets/icons/songgio_meta_tone.svg',
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _MetaCard(
            label: 'Điệu',
            value: 'Ballad',
            valueColor: Colors.white,
            iconAsset: 'assets/icons/songgio_meta_style.svg',
          ),
        ),
      ],
    );
  }
}

class _MetaCard extends StatelessWidget {
  const _MetaCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.iconAsset,
  });

  final String label;
  final String value;
  final Color valueColor;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 79,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 15 / 10,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: GoogleFonts.plusJakartaSans(
                    color: valueColor,
                    fontSize: label == 'Tone' ? 20 : 18,
                    fontWeight: label == 'Tone' ? FontWeight.w800 : FontWeight.w700,
                    height: 28 / (label == 'Tone' ? 20 : 18),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 18, height: 21, child: SvgPicture.asset(iconAsset)),
        ],
      ),
    );
  }
}

class _MediaCard extends StatefulWidget {
  const _MediaCard();

  @override
  State<_MediaCard> createState() => _MediaCardState();
}

class _MediaCardState extends State<_MediaCard> {
  static const List<String> _localVideoAssetCandidates = [
    'assets/videos/song_gio.mp4',
  ];
  static final Uri _videoUri = Uri.parse('https://www.youtube.com/watch?v=j8U06veqxdU&list=RDj8U06veqxdU&start_radio=1');

  VideoPlayerController? _videoController;
  String? _activeVideoAssetPath;
  bool _hasLocalVideo = false;
  bool _isInitializing = true;
  String? _videoError;
  String? _videoErrorDetail;
  bool _isBuffering = false;
  bool _controlsVisible = true;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    _initLocalVideo();
  }

  Future<void> _initLocalVideo() async {
    _hideControlsTimer?.cancel();
    _videoController?.removeListener(_onVideoValueChanged);
    _videoController?.dispose();
    if (mounted) {
      setState(() {
        _videoController = null;
        _activeVideoAssetPath = null;
        _hasLocalVideo = false;
        _isInitializing = true;
        _videoError = null;
        _videoErrorDetail = null;
        _isBuffering = false;
        _controlsVisible = true;
      });
    }

    try {
      VideoPlayerController? controller;
      String? pickedPath;
      Object? lastError;
      final tempDir = await getTemporaryDirectory();

      for (final assetPath in _localVideoAssetCandidates) {
        try {
          final data = await rootBundle.load(assetPath).timeout(const Duration(seconds: 6));
          final outputName = assetPath.split('/').last;
          final outputFile = File('${tempDir.path}${Platform.pathSeparator}$outputName');
          await outputFile.writeAsBytes(
            data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
            flush: true,
          );

          final candidate = VideoPlayerController.file(outputFile);
          await candidate.initialize().timeout(const Duration(seconds: 30));
          await candidate.setLooping(false);
          candidate.addListener(_onVideoValueChanged);
          controller = candidate;
          pickedPath = outputFile.path.replaceAll('\\', '/');
          break;
        } catch (e) {
          lastError = e;
        }
      }

      if (controller == null || pickedPath == null) {
        throw Exception('LOCAL_VIDEO_NOT_AVAILABLE: $lastError');
      }
      if (!mounted) {
        controller.dispose();
        return;
      }
      setState(() {
        _videoController = controller;
        _activeVideoAssetPath = pickedPath;
        _hasLocalVideo = true;
        _isInitializing = false;
        _videoError = null;
        _videoErrorDetail = null;
      });
      await controller.play();
      _scheduleControlsHide();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _hasLocalVideo = false;
        _isInitializing = false;
        _videoError = 'Không mở được video local. Dùng file gốc: assets/videos/song_gio.mp4. Thử restart app sau khi copy file.';
        _videoErrorDetail = e.toString();
      });
    }
  }

  void _onVideoValueChanged() {
    final controller = _videoController;
    if (!mounted || controller == null) {
      return;
    }

    final nextBuffering = controller.value.isBuffering;
    if (nextBuffering != _isBuffering) {
      setState(() {
        _isBuffering = nextBuffering;
      });
    }
  }

  Future<void> _openVideoInBrowser() async {
    await launchUrl(_videoUri, mode: LaunchMode.externalApplication);
  }

  Future<void> _togglePlayPause() async {
    final controller = _videoController;
    if (controller == null) {
      return;
    }
    if (controller.value.isPlaying) {
      await controller.pause();
      _hideControlsTimer?.cancel();
      _controlsVisible = true;
    } else {
      await controller.play();
      _scheduleControlsHide();
    }
    if (mounted) {
      setState(() {});
    }
  }

  void _scheduleControlsHide() {
    _hideControlsTimer?.cancel();
    final controller = _videoController;
    if (controller == null || !controller.value.isPlaying) {
      return;
    }
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) {
        return;
      }
      setState(() {
        _controlsVisible = false;
      });
    });
  }

  void _onTapVideoArea() {
    setState(() {
      _controlsVisible = !_controlsVisible;
    });
    if (_controlsVisible) {
      _scheduleControlsHide();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    final hours = duration.inHours;
    if (hours > 0) {
      return '$hours:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  void _goBack() {
    Navigator.of(context).maybePop();
  }

  Widget _buildQuickBackButton() {
    return Positioned(
      left: 10,
      top: 10,
      child: GestureDetector(
        onTap: _goBack,
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(0, 0, 0, 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
          child: const Center(
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _videoController?.removeListener(_onVideoValueChanged);
    _videoController?.dispose();
    super.dispose();
  }

  Widget _buildLoadingOrError() {
    if (_isInitializing) {
      return const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (_videoError == null) {
      return const SizedBox.shrink();
    }

    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(0, 0, 0, 0.65),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _videoError!,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (_videoErrorDetail != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  _videoErrorDetail!,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFE0E0E0),
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            GestureDetector(
              onTap: _initLocalVideo,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF923E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Thử lại',
                  style: GoogleFonts.splineSans(
                    color: const Color(0xFF1A1A1A),
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = _videoController;
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 335,
            height: 171,
            child: _hasLocalVideo && controller != null
                    ? GestureDetector(
                        onTap: _onTapVideoArea,
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: controller.value.size.width,
                                height: controller.value.size.height,
                                child: VideoPlayer(controller),
                              ),
                            ),
                            if (_isBuffering)
                              Container(
                                color: const Color.fromRGBO(0, 0, 0, 0.32),
                                child: const Center(
                                  child: SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(strokeWidth: 2.5),
                                  ),
                                ),
                              ),
                            if (_controlsVisible)
                              Positioned.fill(
                                child: Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Color.fromRGBO(0, 0, 0, 0.2),
                                        Color.fromRGBO(0, 0, 0, 0.06),
                                        Color.fromRGBO(0, 0, 0, 0.6),
                                      ],
                                      stops: [0.0, 0.55, 1.0],
                                    ),
                                  ),
                                ),
                              ),
                            if (_controlsVisible)
                              Center(
                                child: GestureDetector(
                                  onTap: _togglePlayPause,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      color: const Color.fromRGBO(0, 0, 0, 0.45),
                                      borderRadius: BorderRadius.circular(999),
                                    ),
                                    child: Icon(
                                      controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 28,
                                    ),
                                  ),
                                ),
                              ),
                            if (_controlsVisible)
                              Positioned(
                                left: 12,
                                right: 12,
                                bottom: 8,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    VideoProgressIndicator(
                                      controller,
                                      allowScrubbing: true,
                                      colors: const VideoProgressColors(
                                        playedColor: Color(0xFFFF923E),
                                        bufferedColor: Color.fromRGBO(255, 255, 255, 0.35),
                                        backgroundColor: Color.fromRGBO(255, 255, 255, 0.2),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          _formatDuration(controller.value.position),
                                          style: GoogleFonts.manrope(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          _formatDuration(controller.value.duration),
                                          style: GoogleFonts.manrope(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            _buildQuickBackButton(),
                          ],
                        ),
                      )
                : GestureDetector(
                    onTap: _openVideoInBrowser,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/images/chord_reco_song_gio.png',
                          fit: BoxFit.cover,
                        ),
                        Center(
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, 0.45),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Center(
                              child: SizedBox(
                                width: 18,
                                height: 18,
                                child: SvgPicture.asset('assets/icons/songgio_play_triangle.svg'),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 8,
                          right: 8,
                          bottom: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(0, 0, 0, 0.6),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _activeVideoAssetPath == null
                                  ? 'Đặt video tại: assets/videos/song_gio.mp4'
                                  : 'Đang dùng: $_activeVideoAssetPath',
                              textAlign: TextAlign.center,
                              style: GoogleFonts.manrope(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        _buildQuickBackButton(),
                        if (_isInitializing || _videoError != null) _buildLoadingOrError(),
                      ],
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _openVideoInBrowser,
          child: Text(
            'SÓNG GIÓ | ICM x JACK | OFFICIAL MUSIC VIDEO',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.6,
              decoration: TextDecoration.underline,
              height: 32 / 12,
            ),
          ),
        ),
      ],
    );
  }
}

class _ToolBar extends StatelessWidget {
  const _ToolBar();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromRGBO(60, 60, 60, 0.16),
          borderRadius: BorderRadius.circular(999),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: const [
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_transpose.svg',
              label: 'Đổi tone',
              active: false,
            ),
            SizedBox(width: 8),
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_autoscroll.svg',
              label: 'Tự động cuộn',
              active: false,
            ),
            SizedBox(width: 8),
            _PillButton(
              iconAsset: 'assets/icons/songgio_btn_chord.svg',
              label: 'Hợp âm',
              active: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.iconAsset,
    required this.label,
    required this.active,
  });

  final String iconAsset;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color.fromRGBO(255, 146, 62, 0.1) : const Color.fromRGBO(87, 87, 87, 0.44),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          SizedBox(width: 10.5, height: 10.5, child: SvgPicture.asset(iconAsset)),
          const SizedBox(width: 8),
          Text(
            label,
            style: GoogleFonts.splineSans(
              color: active ? const Color(0xFFFF923E) : Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              height: 20 / 14,
            ),
          ),
        ],
      ),
    );
  }
}

class _LyricsSection extends StatelessWidget {
  const _LyricsSection({required this.onChordTap});

  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(title: 'Verse 1:'),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Hồng ', false),
            _LyricPart('[Am]', true),
            _LyricPart(' trần trên đôi cánh tay', false),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Họa ', false),
            _LyricPart('[Em7]', true),
            _LyricPart(' đời em trong phút giây', false),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Từ ngày thơ ấy còn ngủ mơ ', false),
            _LyricPart('[G]', true),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Đến khi em thờ ơ ờ ', false),
            _LyricPart('[C]', true),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Pre-Chorus:'),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Lòng ', false),
            _LyricPart('[Am]', true),
            _LyricPart(' người anh đâu có hay', false),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Một ', false),
            _LyricPart('[Em7]', true),
            _LyricPart(' ngày khi vỗ cánh bay', false),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Từ người ', false),
            _LyricPart('[G]', true),
            _LyricPart(' yêu hóa thành người dưng', false),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Đến khi ta tự ', false),
            _LyricPart('[Am]', true),
            _LyricPart(' xưng à', false),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 20),
        const _SectionTitle(title: 'Pre-Chorus:'),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Thương em bờ vai nhỏ nhoi ', false),
            _LyricPart('[Fmaj7]', true),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Đôi mắt hoá mây đêm ', false),
            _LyricPart('[G]', true),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 12),
        _ChordLine(
          parts: const [
            _LyricPart('Thương sao mùi ', false),
            _LyricPart('[Em]', true),
            _LyricPart(' dạ lý hương Vương vấn mãi bên ', false),
            _LyricPart('[AM]', true),
            _LyricPart(' thềm', false),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Đời phiêu du cố tìm 1 người thật lòng Dẫu ', false),
            _LyricPart('[F]', true),
            _LyricPart(' trời mênh mông anh nhớ ', false),
            _LyricPart('[G]', true),
            _LyricPart(' em ', false),
            _LyricPart('[F]', true),
            _LyricPart(' Hà ha ha ha há ha', false),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Chim kia về vẫn có đôi Sao chẳng số phu thê ', false),
            _LyricPart('[Fmaj7] [G]', true),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Em ơi đừng xa cách tôi Chẳng cố níu em về ', false),
            _LyricPart('[EM] [Am]', true),
          ],
          onChordTap: onChordTap,
        ),
        _ChordLine(
          parts: const [
            _LyricPart('Bình yên trên mái nhà Nhìn đời ngược dòng Em còn bên anh có phải không ', false),
            _LyricPart('[F] [C] [E]', true),
          ],
          onChordTap: onChordTap,
        ),
        const SizedBox(height: 20),
        _BorderLyricsBlock(
          title: 'CHORUS',
          onChordTap: onChordTap,
          lines: [
            [
              _LyricPart('Trời ban ánh sáng, năm tháng tư bề Dáng ai về chung lối ', false),
              _LyricPart('[Am] [Em]', true),
            ],
            [
              _LyricPart('Người mang tia nắng ', false),
              _LyricPart('[F]', true),
            ],
            [
              _LyricPart('Nhưng cớ sao còn tăm tối ', false),
              _LyricPart('[G] [C] [G]', true),
            ],
            [
              _LyricPart('Một mai em lỡ vấp ngã trên đời thay đổi ', false),
              _LyricPart('[Am] [Em]', true),
            ],
            [
              _LyricPart('Nhìn về anh, người chẳng khiến em lẻ loi ', false),
              _LyricPart('[F] [G] [Am]', true),
            ],
          ],
        ),
        const SizedBox(height: 18),
        _BorderLyricsBlock(
          title: 'RAP',
          onChordTap: onChordTap,
          lines: [
            [
              _LyricPart('Oh! Nếu em có về ', false),
              _LyricPart('[Am]', true),
            ],
            [
              _LyricPart('Anh sẽ mang hết những suy tư', false),
            ],
            [
              _LyricPart('Mang hết hành trang ', false),
              _LyricPart('[Em]', true),
            ],
            [
              _LyricPart('Những ngày sống khổ', false),
            ],
            [
              _LyricPart('Để cho gió biển di cư', false),
            ],
            [
              _LyricPart('Anh thà lênh đênh không có ngày về ', false),
              _LyricPart('[F]', true),
            ],
            [
              _LyricPart('Hóa kiếp thân trai như Thủy Hử', false),
            ],
            [
              _LyricPart('Ta chả bận lòng hay chẳng thể nói ', false),
              _LyricPart('[Em]', true),
            ],
            [
              _LyricPart('Tụi mình có khác gì nhau', false),
            ],
            [
              _LyricPart('Yêu sao cánh điệp phủ mờ nét bút ', false),
              _LyricPart('[F]', true),
            ],
            [
              _LyricPart('Dẫu người chẳng hẹn đến về sau ', false),
              _LyricPart('[G]', true),
            ],
            [
              _LyricPart('Phố thị đèn màu ta chỉ cần chung lối ', false),
              _LyricPart('[Am]', true),
            ],
            [
              _LyricPart('Để rồi sống chết cũng vì nhau', false),
            ],
          ],
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: GoogleFonts.splineSans(
        color: const Color(0xFFFF923E),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _LyricPart {
  const _LyricPart(this.text, this.isChord);

  final String text;
  final bool isChord;
}

class _ChordLine extends StatelessWidget {
  const _ChordLine({required this.parts, required this.onChordTap});

  final List<_LyricPart> parts;
  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: parts
            .map(
              (part) => part.isChord && _extractChordLabel(part.text) != null
                  ? WidgetSpan(
                      alignment: PlaceholderAlignment.baseline,
                      baseline: TextBaseline.alphabetic,
                      child: GestureDetector(
                        onTap: () => onChordTap(_extractChordLabel(part.text)!),
                        behavior: HitTestBehavior.opaque,
                        child: Text(
                          part.text,
                          style: GoogleFonts.splineSans(
                            color: const Color(0xE6FF923E),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            height: 29.25 / 18,
                            letterSpacing: 0.45,
                          ),
                        ),
                      ),
                    )
                  : TextSpan(
                      text: part.text,
                      style: GoogleFonts.splineSans(
                        color: part.isChord ? const Color(0xE6FF923E) : const Color(0xE6FFFFFF),
                        fontSize: 18,
                        fontWeight: part.isChord ? FontWeight.w600 : FontWeight.w400,
                        height: 29.25 / 18,
                        letterSpacing: 0.45,
                      ),
                    ),
            )
            .toList(),
      ),
    );
  }
}

class _BorderLyricsBlock extends StatelessWidget {
  const _BorderLyricsBlock({
    required this.title,
    required this.lines,
    required this.onChordTap,
  });

  final String title;
  final List<List<_LyricPart>> lines;
  final ValueChanged<String> onChordTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 0, 8),
      decoration: const BoxDecoration(
        border: Border(left: BorderSide(color: Color.fromRGBO(255, 146, 62, 0.2), width: 2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.splineSans(
              color: const Color(0xFFFF923E),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.8,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 10),
          ...lines.map(
            (parts) => Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: _ChordLine(parts: parts, onChordTap: onChordTap),
            ),
          ),
        ],
      ),
    );
  }
}

String? _extractChordLabel(String text) {
  final match = RegExp(r'\[(Am|AM|Em7|EM7)\]').firstMatch(text);
  return match?.group(1);
}
