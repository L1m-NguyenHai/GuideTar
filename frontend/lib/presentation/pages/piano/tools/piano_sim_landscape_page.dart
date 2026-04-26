import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PianoSimLandscapePage extends StatefulWidget {
  const PianoSimLandscapePage({super.key});

  @override
  State<PianoSimLandscapePage> createState() => _PianoSimLandscapePageState();
}

class _PianoSimLandscapePageState extends State<PianoSimLandscapePage> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    final content = SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Column(
          children: [
            _CompactHeader(onBack: () => Navigator.of(context).maybePop()),
            const SizedBox(height: 14),
            const Expanded(child: _KeyboardPanel()),
          ],
        ),
      ),
    );

    return Scaffold(
      backgroundColor: const Color(0xFF0B0B0B),
      body: isPortrait
          ? Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: SizedBox(
                  width: size.height,
                  height: size.width,
                  child: content,
                ),
              ),
            )
          : content,
    );
  }
}

class _CompactHeader extends StatelessWidget {
  const _CompactHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'CHAPTER 04 • INTERMEDIATE THEORY',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE4A16B),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Mastering C Major 7',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFF4F4F5),
                    fontSize: 36 * 0.62,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        _ActionButton(
          label: 'SKIP',
          filled: false,
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        _ActionButton(
          label: 'RECORD',
          filled: true,
          onTap: () {},
        ),
        const SizedBox(width: 22),
        SizedBox(
          width: 192,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'PROGRESS',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFADAAAA),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '65%',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFADAAAA),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  height: 4,
                  child: LinearProgressIndicator(
                    value: 0.65,
                    backgroundColor: const Color(0xFF303030),
                    valueColor: const AlwaysStoppedAnimation(Color(0xFFFD8B00)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 31,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: filled ? const Color(0xFFFD8B00) : const Color(0xFF1D1D1D),
          borderRadius: BorderRadius.circular(8),
          boxShadow: filled
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(253, 139, 0, 0.28),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: filled ? const Color(0xFF422000) : const Color(0xFFEAEAEA),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
      ),
    );
  }
}

class _KeyboardPanel extends StatelessWidget {
  const _KeyboardPanel();

  @override
  Widget build(BuildContext context) {
    const whiteKeyWidth = 48.0;
    const whiteKeyHeight = 216.0;
    const blackKeyWidth = 27.0;
    const blackKeyHeight = 154.0;
    const whiteKeyCount = 17;
    const activeWhite = <int>{2, 4, 6, 7};

    final totalWidth = whiteKeyWidth * whiteKeyCount;
    final blackKeyOffsets = <double>[];

    // Pattern: two black keys, then three black keys in each octave span.
    for (var base = 0; base <= 12; base += 7) {
      final local = <double>[0.73, 1.73, 3.73, 4.73, 5.73];
      for (final x in local) {
        final index = base + x;
        if (index < whiteKeyCount - 1) {
          blackKeyOffsets.add(index * whiteKeyWidth - (blackKeyWidth / 2));
        }
      }
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF111111),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.35),
            blurRadius: 26,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(9, 17, 9, 0),
        child: Column(
          children: [
            Container(
              width: 96,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFF2D2D2D),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: totalWidth,
                    height: whiteKeyHeight,
                    child: Stack(
                      children: [
                        Row(
                          children: List.generate(whiteKeyCount, (index) {
                            final highlighted = activeWhite.contains(index);
                            return Container(
                              width: whiteKeyWidth,
                              height: whiteKeyHeight,
                              decoration: BoxDecoration(
                                color: highlighted
                                    ? const Color(0xFFFD8B00)
                                    : const Color(0xFFF0F0F0),
                                border: Border.all(
                                  color: highlighted
                                      ? const Color(0xFFF28A18)
                                      : const Color(0xFFD2D2D2),
                                ),
                              ),
                              alignment: Alignment.bottomCenter,
                              padding: const EdgeInsets.only(bottom: 20),
                              child: Text(
                                index == 2
                                    ? 'E4'
                                    : index == 4
                                        ? 'G4'
                                        : index == 6
                                            ? 'B4'
                                            : index == 7
                                                ? 'C5'
                                                : '',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF9A5500),
                                  fontSize: 18 * 0.53,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            );
                          }),
                        ),
                        ...blackKeyOffsets.map(
                          (left) => Positioned(
                            left: left,
                            top: 0,
                            child: Container(
                              width: blackKeyWidth,
                              height: blackKeyHeight,
                              decoration: BoxDecoration(
                                color: const Color(0xFF090909),
                                borderRadius: const BorderRadius.only(
                                  bottomLeft: Radius.circular(6),
                                  bottomRight: Radius.circular(6),
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color.fromRGBO(0, 0, 0, 0.28),
                                    blurRadius: 10,
                                    offset: Offset(0, 6),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
