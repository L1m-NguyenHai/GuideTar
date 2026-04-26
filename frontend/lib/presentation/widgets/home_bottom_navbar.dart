import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeBottomNavbar extends StatelessWidget {
  const HomeBottomNavbar({
    super.key,
    required this.selectedIndex,
    required this.onChanged,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;

  static const List<double> _cutoutLeft = [21, 99, 179, 257];
  static const List<double> _bubbleLeft = [48, 126, 206, 284];
  static const List<double> _itemLeft = [37, 116, 195, 274];
  static const List<String> _activeIconAssets = [
    'assets/icons/nav_home.svg',
    'assets/icons/nav_learn_active.svg',
    'assets/icons/nav_profile_active.svg',
    'assets/icons/nav_recent_active.svg',
  ];

  static const List<String> _inactiveIconAssets = [
    'assets/icons/nav_home_inactive.svg',
    'assets/icons/nav_learn.svg',
    'assets/icons/nav_profile.svg',
    'assets/icons/nav_recent.svg',
  ];

  static const _animDuration = Duration(milliseconds: 280);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      width: 390,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _animDuration,
            curve: Curves.easeOutCubic,
            left: _cutoutLeft[selectedIndex],
            top: 10,
            child: SizedBox(
              width: 110,
              height: 56,
              child: SvgPicture.asset('assets/icons/nav_cutout.svg'),
            ),
          ),
          AnimatedPositioned(
            duration: _animDuration,
            curve: Curves.easeOutCubic,
            left: _bubbleLeft[selectedIndex],
            top: 0,
            child: SizedBox(
              width: 56,
              height: 56,
              child: SvgPicture.asset('assets/icons/nav_orange_circle.svg'),
            ),
          ),
          for (var i = 0; i < _inactiveIconAssets.length; i++)
            AnimatedPositioned(
              key: ValueKey('nav-item-$i'),
              duration: _animDuration,
              curve: Curves.easeOutCubic,
              left: _itemLeft[i],
              top: selectedIndex == i ? 10 : 30,
              child: GestureDetector(
                onTap: () => onChanged(i),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 78,
                  height: 40,
                  child: Center(
                    child: SizedBox(
                      width: i == 2 ? 18 : 78,
                      height: i == 2 ? 18 : 40,
                      child: SvgPicture.asset(
                        selectedIndex == i ? _activeIconAssets[i] : _inactiveIconAssets[i],
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
