import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/guitar/tools/pro_tuner_settings_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class ProTunerPage extends StatefulWidget {
  const ProTunerPage({super.key});

  @override
  State<ProTunerPage> createState() => _ProTunerPageState();
}

class _ProTunerPageState extends State<ProTunerPage> {
  static const String _settingsAsset = 'assets/images/pro_tuner_settings.png';
  static const String _centerLineAsset = 'assets/icons/pro_tuner_center_line.svg';
  static const String _pitchRingAsset = 'assets/icons/pro_tuner_pitch_ring.svg';
  static const String _pitchNeedleAsset = 'assets/icons/pro_tuner_pitch_needle.svg';
  static const String _neckAsset = 'assets/images/pro_tuner_neck.png';
  static const String _stepperPlayAsset = 'assets/icons/pro_tuner_stepper_play.svg';

  int _selectedNavIndex = 2;
  bool _isAuto = true;
  int _selectedStringIndex = 1;

  static const List<String> _strings = ['E', 'A', 'D', 'G', 'B', 'e'];

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
              padding: const EdgeInsets.fromLTRB(6, 17, 6, 140),
              child: Column(
                children: [
                  _Header(
                    settingsAsset: _settingsAsset,
                    onBackTap: () {
                      if (Navigator.of(context).canPop()) {
                        Navigator.of(context).pop();
                      }
                    },
                    onSettingsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ProTunerSettingsPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 7),
                  _ModeToggle(
                    isAuto: _isAuto,
                    onChanged: (value) {
                      setState(() {
                        _isAuto = value;
                      });
                    },
                  ),
                  const SizedBox(height: 13),
                  _PitchIndicator(
                    ringAsset: _pitchRingAsset,
                    needleAsset: _pitchNeedleAsset,
                    value: '+5',
                  ),
                  const SizedBox(height: 13),
                  _NeckStage(
                    neckAsset: _neckAsset,
                    centerLineAsset: _centerLineAsset,
                    stepperPlayAsset: _stepperPlayAsset,
                    strings: _strings,
                    selectedIndex: _selectedStringIndex,
                    onStringSelected: (value) {
                      setState(() {
                        _selectedStringIndex = value;
                      });
                    },
                  ),
                  Transform.translate(
                    offset: const Offset(0, -14),
                    child: _BottomStringsBar(
                      strings: _strings,
                      selectedIndex: _selectedStringIndex,
                      onChanged: (value) {
                        setState(() {
                          _selectedStringIndex = value;
                        });
                      },
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

class _Header extends StatelessWidget {
  const _Header({
    required this.settingsAsset,
    required this.onBackTap,
    required this.onSettingsTap,
  });

  final String settingsAsset;
  final VoidCallback onBackTap;
  final VoidCallback onSettingsTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0x662A2A29),
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ProTuner',
                  style: GoogleFonts.splineSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.6,
                    height: 32 / 24,
                  ),
                ),
                Text(
                  'E STANDARD',
                  style: GoogleFonts.splineSans(
                    color: const Color(0xFFF48C25),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onSettingsTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Image.asset(settingsAsset, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeToggle extends StatelessWidget {
  const _ModeToggle({required this.isAuto, required this.onChanged});

  final bool isAuto;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 256,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          children: [
            Expanded(
              child: _ModeChip(
                text: 'Tự Động',
                selected: isAuto,
                onTap: () => onChanged(true),
              ),
            ),
            Expanded(
              child: _ModeChip(
                text: 'Thủ công',
                selected: !isAuto,
                onTap: () => onChanged(false),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({required this.text, required this.selected, required this.onTap});

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFF58220) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.25),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          text.toUpperCase(),
          textAlign: TextAlign.center,
          style: GoogleFonts.spaceGrotesk(
            color: selected ? const Color(0xFF5B2A00) : const Color(0xFFDDC1B0),
            fontSize: 12,
            letterSpacing: 1.2,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}

class _PitchIndicator extends StatelessWidget {
  const _PitchIndicator({required this.ringAsset, required this.needleAsset, required this.value});

  final String ringAsset;
  final String needleAsset;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 47.52,
      height: 56.57,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 0,
            child: SizedBox(
              width: 47.52,
              height: 47.52,
              child: SvgPicture.asset(ringAsset),
            ),
          ),
          Positioned(
            top: 15,
            child: Text(
              value,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20.48,
                fontWeight: FontWeight.w500,
                height: 17.918 / 20.48,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: 8,
              height: 10.2,
              child: SvgPicture.asset(needleAsset),
            ),
          ),
        ],
      ),
    );
  }
}

class _NeckStage extends StatelessWidget {
  const _NeckStage({
    required this.neckAsset,
    required this.centerLineAsset,
    required this.stepperPlayAsset,
    required this.strings,
    required this.selectedIndex,
    required this.onStringSelected,
  });

  final String neckAsset;
  final String centerLineAsset;
  final String stepperPlayAsset;
  final List<String> strings;
  final int selectedIndex;
  final ValueChanged<int> onStringSelected;

  @override
  Widget build(BuildContext context) {
    const designWidth = 402.0;
    const designHeight = 560.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth < designWidth ? constraints.maxWidth / designWidth : 1.0;

        return SizedBox(
          width: constraints.maxWidth,
          height: designHeight * scale,
          child: FittedBox(
            fit: BoxFit.contain,
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: designWidth,
              height: designHeight,
              child: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 200,
                    child: SizedBox(
                      width: 2,
                      height: 540,
                      child: SvgPicture.asset(centerLineAsset, fit: BoxFit.fill),
                    ),
                  ),
                  Positioned(
                    left: 76.75,
                    top: 70,
                    child: SizedBox(
                      width: 248.5,
                      height: 471,
                      child: Image.asset(neckAsset, fit: BoxFit.cover),
                    ),
                  ),
                  _SideStepper(
                    left: 6,
                    top: 117,
                    label: strings[2],
                    selected: selectedIndex == 2,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(2),
                  ),
                  _SideStepper(
                    left: 340,
                    top: 117,
                    label: strings[3],
                    selected: selectedIndex == 3,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(3),
                  ),
                  _SideStepper(
                    left: 6,
                    top: 199,
                    label: strings[1],
                    selected: selectedIndex == 1,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(1),
                  ),
                  _SideStepper(
                    left: 340,
                    top: 198,
                    label: strings[4],
                    selected: selectedIndex == 4,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(4),
                  ),
                  _SideStepper(
                    left: 6,
                    top: 279,
                    label: strings[0],
                    selected: selectedIndex == 0,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(0),
                  ),
                  _SideStepper(
                    left: 340,
                    top: 279,
                    label: strings[5],
                    selected: selectedIndex == 5,
                    playAsset: stepperPlayAsset,
                    onTap: () => onStringSelected(5),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SideStepper extends StatelessWidget {
  const _SideStepper({
    required this.left,
    required this.top,
    required this.label,
    required this.selected,
    required this.playAsset,
    required this.onTap,
  });

  final double left;
  final double top;
  final String label;
  final bool selected;
  final String playAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: left,
      top: top,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 49.78,
          height: 49.78,
          padding: const EdgeInsets.all(11.313),
          decoration: BoxDecoration(
            color: selected ? const Color(0xFFD5B58C) : null,
            gradient: selected
                ? null
                : const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [Color(0xFF262626), Color(0xFF333333)],
                    stops: [0.19, 1.0],
                  ),
            borderRadius: BorderRadius.circular(36.202),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.45),
                      blurRadius: 3.394,
                      offset: Offset(0, 1.131),
                    ),
                  ]
                : const [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.45),
                      blurRadius: 5.657,
                      offset: Offset(3.394, 3.394),
                    ),
                  ],
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: SvgPicture.asset(
                  playAsset,
                  colorFilter: ColorFilter.mode(
                    selected ? Colors.black : Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              Center(
                child: Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    color: selected ? Colors.black : Colors.white,
                    fontSize: 18.101,
                    fontWeight: FontWeight.w500,
                    height: 15.838 / 18.101,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomStringsBar extends StatelessWidget {
  const _BottomStringsBar({
    required this.strings,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> strings;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth < 402 ? constraints.maxWidth : 402.0;
        return SizedBox(
          width: width,
          height: 98,
          child: Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                for (int i = 0; i < strings.length; i++)
                  _BottomStringButton(
                    label: strings[i],
                    selected: selectedIndex == i,
                    onTap: () => onChanged(i),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BottomStringButton extends StatelessWidget {
  const _BottomStringButton({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 48,
        height: 48,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFF353534),
          borderRadius: BorderRadius.circular(999),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, 0.35),
                    blurRadius: 14,
                    offset: Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            height: 20 / 14,
          ),
        ),
      ),
    );
  }
}
