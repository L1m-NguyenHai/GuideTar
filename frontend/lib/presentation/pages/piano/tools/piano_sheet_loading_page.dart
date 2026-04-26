import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/piano/tools/piano_sheet_player_page.dart';

class PianoSheetLoadingPage extends StatefulWidget {
  const PianoSheetLoadingPage({super.key});

  @override
  State<PianoSheetLoadingPage> createState() => _PianoSheetLoadingPageState();
}

class _PianoSheetLoadingPageState extends State<PianoSheetLoadingPage> {
  int _progress = 10;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 280), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_progress >= 100) {
        timer.cancel();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const PianoSheetPlayerPage()),
        );
        return;
      }

      setState(() {
        _progress += 10;
        if (_progress > 100) {
          _progress = 100;
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = _progress / 100;

    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 192,
                          height: 192,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const SizedBox(
                                width: 128,
                                height: 128,
                                child: _SafeSvgAsset(
                                  'assets/icons/piano_sheet_loading_ring.svg',
                                ),
                              ),
                              CircularProgressIndicator(
                                value: progressValue,
                                strokeWidth: 4,
                                backgroundColor: const Color(0xFF22262F),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFFF9F4A),
                                ),
                              ),
                              const SizedBox(
                                width: 18,
                                height: 27,
                                child: _SafeSvgAsset(
                                  'assets/icons/piano_sheet_loading_center.svg',
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Đang tải tệp...',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFECEDF6),
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.6,
                            height: 32 / 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Đang tối ưu hoá âm thanh cho sheet nhạc',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9ABB3),
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 24 / 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: 192,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(9999),
                            child: LinearProgressIndicator(
                              value: progressValue,
                              minHeight: 4,
                              backgroundColor: const Color(0xFF161A21),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF9F4A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_progress%',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9ABB3),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 16 / 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Container(
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10131A),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color.fromRGBO(69, 72, 79, 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: SizedBox(
                              width: 48,
                              height: 48,
                              child: Opacity(
                                opacity: 0.5,
                                child: Image.asset(
                                  'assets/images/piano_sheet_loading_file.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '50 năm về sau',
                                  style: TextStyle(
                                    color: Color(0xFFECEDF6),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    height: 20 / 14,
                                  ),
                                ),
                                Text(
                                  '24.5 MB • Lossless Audio',
                                  style: TextStyle(
                                    color: Color(0xFFA9ABB3),
                                    fontSize: 12,
                                    height: 16 / 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 16.667,
                            height: 16.667,
                            child: _SafeSvgAsset(
                              'assets/icons/piano_sheet_loading_file_icon.svg',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _TopBar(),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      color: const Color(0xFF0B0E14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: _SafeSvgAsset('assets/icons/piano_sheet_back.svg'),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Chơi sheet nhạc',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFECEDF6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.45,
                  height: 28 / 18,
                ),
              ),
            ],
          ),
          const SizedBox(
            width: 20.1,
            height: 20,
            child: _SafeSvgAsset('assets/icons/piano_sheet_more.svg'),
          ),
        ],
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
      placeholderBuilder: (context) => Center(
        child: Icon(Icons.image_not_supported, size: 14, color: const Color(0xFF717171)),
      ),
    );
  }
}
