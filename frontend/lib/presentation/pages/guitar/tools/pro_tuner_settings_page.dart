import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

enum _TransposeKey { c, bb, eb, f }

class ProTunerSettingsPage extends StatefulWidget {
  const ProTunerSettingsPage({super.key});

  @override
  State<ProTunerSettingsPage> createState() => _ProTunerSettingsPageState();
}

class _ProTunerSettingsPageState extends State<ProTunerSettingsPage> {
  int _selectedNavIndex = 2;
  double _damping = 0.56;
  double _sensitivity = 0.27;
  _TransposeKey _transposeKey = _TransposeKey.c;

  void _onNavChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }

    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(32, 24, 32, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).maybePop(),
                    behavior: HitTestBehavior.opaque,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.arrow_back_rounded,
                          color: Color(0xFFF7B36B),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'CÀI ĐẶT',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFD6D0CC),
                            fontSize: 28 / 2,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 2,
                            height: 20 / 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Tuner Settings',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE6E6E6),
                      fontSize: 56 / 2,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Hiệu chỉnh thiết bị giám sát của bạn.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8E8E93),
                      fontSize: 19 / 2,
                      fontWeight: FontWeight.w500,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 28),
                  _SliderCard(
                    title: 'DAMPING',
                    subtitle: 'Kiểm soát độ phản hồi',
                    value: _damping,
                    onChanged: (v) => setState(() => _damping = v),
                  ),
                  const SizedBox(height: 20),
                  _SliderCard(
                    title: 'SENSITIVITY',
                    subtitle: 'Kiểm soát độ nhạy',
                    value: _sensitivity,
                    onChanged: (v) => setState(() => _sensitivity = v),
                  ),
                  const SizedBox(height: 26),
                  Row(
                    children: [
                      const Icon(
                        Icons.swap_horiz_rounded,
                        color: Color(0xFFF7B36B),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'CHUYỂN VỊ',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFD8AE81),
                          fontSize: 29 / 2,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2,
                          height: 20 / 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1F22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: _TransposeChip(
                            label: 'C',
                            selected: _transposeKey == _TransposeKey.c,
                            onTap: () => setState(() => _transposeKey = _TransposeKey.c),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TransposeChip(
                            label: 'Bb',
                            selected: _transposeKey == _TransposeKey.bb,
                            onTap: () => setState(() => _transposeKey = _TransposeKey.bb),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TransposeChip(
                            label: 'Eb',
                            selected: _transposeKey == _TransposeKey.eb,
                            onTap: () => setState(() => _transposeKey = _TransposeKey.eb),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _TransposeChip(
                            label: 'F',
                            selected: _transposeKey == _TransposeKey.f,
                            onTap: () => setState(() => _transposeKey = _TransposeKey.f),
                          ),
                        ),
                      ],
                    ),
                  ),
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
}

class _SliderCard extends StatelessWidget {
  const _SliderCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1F),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.tune_rounded, color: Color(0xFFF7B36B), size: 16),
              const SizedBox(width: 6),
              Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFCFAE89),
                  fontSize: 31 / 2,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  height: 20 / 15.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFF8E8E93),
              fontSize: 14,
              fontWeight: FontWeight.w500,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 26),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF6D6D70),
              inactiveTrackColor: const Color(0xFF6D6D70),
              trackHeight: 2,
              thumbColor: const Color(0xFFFAC38A),
              overlayColor: const Color.fromRGBO(250, 195, 138, 0.18),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              min: 0,
              max: 1,
              value: value,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nhanh',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF7E7E82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                ),
              ),
              Text(
                'Chính xác',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF7E7E82),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 20 / 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TransposeChip extends StatelessWidget {
  const _TransposeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF08E2E) : const Color(0xFF3A3A3D),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: selected ? const Color(0xFF4B2800) : const Color(0xFFE0E0E0),
            fontSize: 31 / 2,
            fontWeight: FontWeight.w700,
            height: 20 / 15.5,
          ),
        ),
      ),
    );
  }
}
