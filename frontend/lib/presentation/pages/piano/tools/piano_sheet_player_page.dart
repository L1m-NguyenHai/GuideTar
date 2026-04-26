import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class PianoSheetPlayerPage extends StatelessWidget {
  const PianoSheetPlayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 64),
              Expanded(
                child: Column(
                  children: [
                    Container(
                      height: 241,
                      width: double.infinity,
                      color: const Color(0xFF10131A),
                      alignment: Alignment.center,
                      child: Text(
                        'Sheet Digital',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFECEDF6),
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Stack(
                        children: [
                          _WaterfallGrid(),
                          const _FallingNotes(),
                          const Align(
                            alignment: Alignment.bottomCenter,
                            child: ColoredBox(
                              color: Color.fromRGBO(255, 159, 74, 0.4),
                              child: SizedBox(
                                height: 2,
                                width: double.infinity,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const _PianoKeys(),
                  ],
                ),
              ),
            ],
          ),
          const _TopBar(),
          const Positioned(
            left: 24,
            right: 24,
            bottom: 142,
            child: _PlayerOverlay(),
          ),
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
            '50 năm về sau',
            style: GoogleFonts.inter(
              color: const Color(0xFFECEDF6),
              fontSize: 18,
              fontWeight: FontWeight.w600,
              height: 20 / 18,
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterfallGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        12,
        (index) => Expanded(
          child: Container(
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: Color.fromRGBO(115, 117, 125, 0.05)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FallingNotes extends StatelessWidget {
  const _FallingNotes();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.maxHeight;
        return Stack(
          children: [
            _note(
              left: 0.09 * constraints.maxWidth,
              top: 0.20 * h,
              height: 0.27 * h,
              colorA: const Color(0xFFFF9F4A),
              colorB: const Color(0xFFFD8B00),
            ),
            _note(
              left: 0.17 * constraints.maxWidth,
              top: 0.40 * h,
              height: 0.18 * h,
              colorA: const Color(0xFF7FE6DB),
              colorB: const Color(0xFF006A63),
            ),
            _note(
              left: 0.25 * constraints.maxWidth,
              top: 0.10 * h,
              height: 0.35 * h,
              colorA: const Color(0xFFFF9F4A),
              colorB: const Color(0xFFFD8B00),
            ),
            _note(
              left: 0.50 * constraints.maxWidth,
              top: 0.30 * h,
              height: 0.45 * h,
              colorA: const Color(0xFF7FE6DB),
              colorB: const Color(0xFF006A63),
            ),
            _note(
              left: 0.66 * constraints.maxWidth,
              top: 0.60 * h,
              height: 0.25 * h,
              colorA: const Color(0xFFFF9F4A),
              colorB: const Color(0xFFFD8B00),
            ),
          ],
        );
      },
    );
  }

  Widget _note({
    required double left,
    required double top,
    required double height,
    required Color colorA,
    required Color colorB,
  }) {
    return Positioned(
      left: left,
      top: top,
      width: 16,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [colorA, colorB],
          ),
        ),
      ),
    );
  }
}

class _PianoKeys extends StatelessWidget {
  const _PianoKeys();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 128,
      child: Row(
        children: List.generate(
          14,
          (i) => Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFECEDF6),
                border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.05)),
              ),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 76,
                  color: (i % 7 == 0 || i % 7 == 3)
                      ? Colors.transparent
                      : Colors.black,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlayerOverlay extends StatelessWidget {
  const _PlayerOverlay();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(22, 26, 33, 0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(69, 72, 79, 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFFFF9F4A),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const SizedBox(
              width: 15,
              height: 18,
              child: _SafeSvgAsset('assets/icons/piano_sheet_player_play.svg'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _meta('01:42'),
                    Row(
                      children: [
                        const SizedBox(
                          width: 10.5,
                          height: 12.25,
                          child: _SafeSvgAsset(
                            'assets/icons/piano_sheet_player_bpm.svg',
                          ),
                        ),
                        const SizedBox(width: 8),
                        _meta('72 BPM'),
                      ],
                    ),
                    _meta('04:15'),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(9999),
                  child: LinearProgressIndicator(
                    value: 0.38,
                    minHeight: 6,
                    backgroundColor: const Color(0xFF22262F),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFF9F4A),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 18,
            height: 21,
            child: _SafeSvgAsset('assets/icons/piano_sheet_player_ctrl_1.svg'),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 20,
            height: 16,
            child: _SafeSvgAsset('assets/icons/piano_sheet_player_ctrl_2.svg'),
          ),
          const SizedBox(width: 8),
          const SizedBox(
            width: 18,
            height: 18,
            child: _SafeSvgAsset('assets/icons/piano_sheet_player_ctrl_3.svg'),
          ),
        ],
      ),
    );
  }

  Widget _meta(String text) {
    return Text(
      text,
      style: GoogleFonts.inter(
        color: const Color(0xFFA9ABB3),
        fontSize: 10,
        fontWeight: FontWeight.w500,
        letterSpacing: 1,
        height: 15 / 10,
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
