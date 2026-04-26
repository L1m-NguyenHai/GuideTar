import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

class GuitarEarTrainingPage extends StatefulWidget {
  const GuitarEarTrainingPage({super.key});

  @override
  State<GuitarEarTrainingPage> createState() => _GuitarEarTrainingPageState();
}

class _GuitarEarTrainingPageState extends State<GuitarEarTrainingPage> {
  bool _isListeningPressed = false;

  Future<void> _handleListeningTap() async {
    if (_isListeningPressed) {
      return;
    }

    setState(() {
      _isListeningPressed = true;
    });

    await Future<void>.delayed(const Duration(milliseconds: 420));
    if (!mounted) {
      return;
    }

    setState(() {
      _isListeningPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
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
                            child: _SafeSvgAsset(
                              'assets/icons/guitar_ear_training_back.svg',
                            ),
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
                      onTap: () {},
                      behavior: HitTestBehavior.opaque,
                      child: SizedBox(
                        width: 20.1,
                        height: 20,
                        child: _SafeSvgAsset(
                          'assets/icons/guitar_ear_training_more.svg',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ListeningSection(
                      isPressed: _isListeningPressed,
                      onTap: _handleListeningTap,
                    ),
                    const SizedBox(height: 48),
                    const _ChoiceGrid(),
                    const SizedBox(height: 48),
                    _PrimaryActionButton(onTap: () {}, label: 'Tiếp theo'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ListeningSection extends StatelessWidget {
  const _ListeningSection({required this.isPressed, required this.onTap});

  final bool isPressed;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 192,
            height: 192,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Center(
                    child: Container(
                      width: 256,
                      height: 256,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color.fromRGBO(255, 146, 62, 0.1),
                        boxShadow: [
                          BoxShadow(
                            color: Color.fromRGBO(245, 124, 0, 0.15),
                            blurRadius: 20,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onTap,
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    curve: Curves.easeOut,
                    width: 192,
                    height: 192,
                    decoration: BoxDecoration(
                      color: const Color(0xFF20201F),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: isPressed
                              ? const Color.fromRGBO(255, 146, 62, 0.3)
                              : const Color.fromRGBO(245, 124, 0, 0.15),
                          blurRadius: isPressed ? 68 : 50,
                          offset: Offset.zero,
                        ),
                      ],
                      border: Border.all(
                        color: isPressed
                            ? const Color.fromRGBO(255, 146, 62, 0.5)
                            : const Color.fromRGBO(255, 146, 62, 0.2),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 140),
                      child: isPressed
                          ? SizedBox(
                              key: const ValueKey('pressed-wave'),
                              width: 126,
                              height: 50,
                              child: Image.asset(
                                'assets/images/guitar_ear_training_sound_pressed.png',
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                              ),
                            )
                          : SizedBox(
                              key: const ValueKey('listen-icon'),
                              width: 54,
                              height: 52.5,
                              child: _SafeSvgAsset(
                                'assets/icons/guitar_ear_training_listen.svg',
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Thử thách mới',
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              color: const Color(0xFFFF923E),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              height: 15 / 10,
            ),
          ),
          const SizedBox(height: 8.5),
          SizedBox(
            width: 290,
            child: Text(
              'Nghe và nhận diện',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.75,
                height: 36 / 30,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 235,
      width: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final totalWidth = constraints.maxWidth;
          final gap = 7.0;
          final leftWidth = math.min(
            172.0,
            math.max(0.0, (totalWidth - gap) * 0.5),
          );
          final rightWidth = math.max(0.0, totalWidth - leftWidth - gap);

          return Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: leftWidth,
                height: 86,
                child: const _ChoiceCard(
                  title: 'Trưởng',
                  subtitle: 'Major',
                  titleWidth: 70,
                  compact: true,
                ),
              ),
              Positioned(
                left: leftWidth + gap,
                top: 0,
                width: rightWidth,
                height: 86,
                child: const _ChoiceCard(
                  title: 'Thứ',
                  subtitle: 'Minor',
                  titleWidth: 44,
                  compact: true,
                ),
              ),
              Positioned(
                left: 0,
                top: 102.5,
                width: leftWidth,
                height: 132,
                child: const _ChoiceCard(
                  title: 'Trưởng Hòa Thanh',
                  subtitle: 'Harmonic Major',
                  titleWidth: 136,
                  titleHeight: 45,
                ),
              ),
              Positioned(
                left: leftWidth + gap,
                top: 102.5,
                width: rightWidth,
                height: 132,
                child: const _ChoiceCard(
                  title: 'Thứ Hòa Thanh',
                  subtitle: 'Harmonic Minor',
                  titleWidth: 132,
                  titleHeight: 45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.title,
    required this.subtitle,
    required this.titleWidth,
    this.titleHeight,
    this.compact = false,
  });

  final String title;
  final String subtitle;
  final double titleWidth;
  final double? titleHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        25,
        compact ? 20 : 25,
        25,
        compact ? 18 : 25,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: titleWidth,
            height: titleHeight ?? (compact ? 24 : null),
            child: Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: titleHeight != null
                    ? 22.5 / 18
                    : (compact ? 24 / 18 : 28 / 18),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(height: compact ? 1 : 2),
          Text(
            subtitle,
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontSize: 12,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.6,
              height: 16 / 12,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
              blurRadius: 32,
              offset: Offset(0, 12),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF4D2300),
            fontSize: 18,
            fontWeight: FontWeight.w800,
            height: 28 / 18,
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
      placeholderBuilder: (context) => Center(
        child: Icon(Icons.image_not_supported, size: 16, color: const Color(0xFF717171)),
      ),
    );
  }
}
