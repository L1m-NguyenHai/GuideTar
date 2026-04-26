import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MatBiecPage extends StatelessWidget {
  const MatBiecPage({super.key});

  static const _waveHeights = <double>[
    38.39,
    25.59,
    51.19,
    64,
    48,
    51.19,
    25.59,
    38.39,
    25.59,
    38.39,
    25.59,
    51.19,
    38.39,
    25.59,
    48,
    12.8,
    38.39,
    25.59,
    51.19,
    64,
    48,
    51.19,
    25.59,
    38.39,
    25.59,
    38.39,
    51.19,
    25.59,
    38.39,
    25.59,
    48,
    51.19,
    25.59,
    38.39,
    25.59,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 96, 24, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PlayerCard(waveHeights: _waveHeights),
                  const SizedBox(height: 40),
                  Text(
                    'Chords:',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 28 / 20,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _ChordRow(),
                  const SizedBox(height: 32),
                  Text(
                    'Hợp âm',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                      height: 28 / 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _TempoCard(),
                ],
              ),
            ),
            const _TopBar(),
          ],
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: 0,
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(38, 38, 38, 0.9),
          border: Border(bottom: BorderSide(color: const Color.fromRGBO(72, 72, 71, 0.1))),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).maybePop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(255, 255, 255, 0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 16),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mắt Biếc',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFF923E),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.45,
                        height: 28 / 18,
                      ),
                    ),
                    Text(
                      'Phan Mạnh Quỳnh',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFADAAAA),
                        fontSize: 10,
                        letterSpacing: 1,
                        height: 15 / 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 146, 62, 0.1),
                    border: Border.all(color: const Color.fromRGBO(255, 146, 62, 0.2)),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.auto_awesome, color: Color(0xFFFF923E), size: 13),
                      const SizedBox(width: 6),
                      Text(
                        '99% AI ACCURACY',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFF923E),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 16.5 / 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {},
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: const Icon(Icons.more_vert, color: Color(0xFFFF923E), size: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  const _PlayerCard({required this.waveHeights});

  final List<double> waveHeights;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 38, 38, 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.1)),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.25),
            blurRadius: 50,
            offset: Offset(0, 25),
            spreadRadius: -12,
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            width: 160,
            height: 160,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/images/dechord_modal_selected_bg.png'),
                        fit: BoxFit.fill,
                      ),
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color.fromRGBO(14, 14, 14, 0), Color.fromRGBO(14, 14, 14, 0.4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 64,
            child: ClipRect(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.bottomLeft,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (final height in waveHeights) ...[
                      Container(
                        width: 4,
                        height: height,
                        decoration: BoxDecoration(
                          color: height > 48
                              ? const Color(0xFFFF923E)
                              : height > 32
                                  ? const Color.fromRGBO(255, 146, 62, 0.6)
                                  : const Color.fromRGBO(255, 146, 62, 0.4),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                      ),
                      const SizedBox(width: 2),
                    ],
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Column(
            children: [
              _ProgressBar(),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1:12',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFADAAAA),
                      fontSize: 10,
                      letterSpacing: 0.5,
                      height: 15 / 10,
                    ),
                  ),
                  Text(
                    '3:45',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFADAAAA),
                      fontSize: 10,
                      letterSpacing: 0.5,
                      height: 15 / 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          FractionallySizedBox(
            widthFactor: 0.33,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFF923E),
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(-0.33, 0),
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9999),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChordRow extends StatelessWidget {
  const _ChordRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _ChordBlock(label: 'D#', size: 100, textColor: Colors.black),
        SizedBox(width: 9),
        _ChordBlock(label: 'Gm', size: 123, textColor: Color(0xFF99200B)),
        SizedBox(width: 9),
        _ChordBlock(label: 'Cm', size: 100, textColor: Colors.black),
      ],
    );
  }
}

class _ChordBlock extends StatelessWidget {
  const _ChordBlock({required this.label, required this.size, required this.textColor});

  final String label;
  final double size;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFB5B5B5),
        borderRadius: BorderRadius.circular(26),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: GoogleFonts.plusJakartaSans(
          color: textColor,
          fontSize: size == 123 ? 48 : 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          height: 28 / (size == 123 ? 48 : 32),
        ),
      ),
    );
  }
}

class _TempoCard extends StatelessWidget {
  const _TempoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 147,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 38, 38, 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.1)),
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          'Tempo: 83\nNhịp: 4/4\nVòng hợp âm: [D#] [Gm] [Cm]\n[G#]',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFF99200B),
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 28 / 20,
          ),
        ),
      ),
    );
  }
}
