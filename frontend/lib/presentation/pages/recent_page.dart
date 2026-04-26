import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';
import 'package:guidetar/presentation/pages/profile_page.dart';

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});

  @override
  State<RecentPage> createState() => _RecentPageState();
}

class _RecentPageState extends State<RecentPage> {
  int _selectedNavIndex = 3;

  void _onNavbarChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 89, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _RecentEditorialHeader(),
                  SizedBox(height: 40),
                  _RecentCoursesSection(),
                  SizedBox(height: 32),
                  _RecentToolsSection(),
                ],
              ),
            ),
          ),
          const _RecentTopBar(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Center(
              child: HomeBottomNavbar(
                selectedIndex: _selectedNavIndex,
                onChanged: _onNavbarChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentTopBar extends StatelessWidget {
  const _RecentTopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      decoration: const BoxDecoration(color: Color.fromRGBO(9, 9, 11, 0.6)),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: _SafeSvgAsset('assets/icons/recent_header_left.svg'),
              ),
              const SizedBox(width: 16),
              Text(
                'Gần đây',
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
          SizedBox(
            width: 20.1,
            height: 20,
            child: _SafeSvgAsset('assets/icons/recent_header_right.svg'),
          ),
        ],
      ),
    );
  }
}

class _RecentEditorialHeader extends StatelessWidget {
  const _RecentEditorialHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HỌC TẬP & LUYỆN TẬP',
          style: GoogleFonts.manrope(
            color: const Color(0xFFFF923E),
            fontSize: 10,
            fontWeight: FontWeight.w700,
            letterSpacing: 2,
            height: 15 / 10,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Gần đây',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 36,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.w800,
            letterSpacing: -1.8,
            height: 1,
          ),
        ),
      ],
    );
  }
}

class _RecentCoursesSection extends StatelessWidget {
  const _RecentCoursesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Khóa học',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 28 / 20,
              ),
            ),
            Text(
              'Xem tất cả',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFF923E),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const _RecentCourseCard(
          imageAsset: 'assets/images/recent_course_1.png',
          category: 'Guitar cơ bản',
          title: 'Thầy Hải',
          description: 'Thuần học vẹt',
        ),
        const SizedBox(height: 16),
        const _RecentCourseCard(
          imageAsset: 'assets/images/recent_course_2.png',
          category: 'Piano cơ bản',
          title: 'Khầy Quyền',
          description: 'Master Piano trong vài nốt nhạc , tin khầy',
        ),
      ],
    );
  }
}

class _RecentCourseCard extends StatelessWidget {
  const _RecentCourseCard({
    required this.imageAsset,
    required this.category,
    required this.title,
    required this.description,
  });

  final String imageAsset;
  final String category;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.05)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.toUpperCase(),
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFFFD262),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 15 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentToolsSection extends StatelessWidget {
  const _RecentToolsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Công cụ',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        SizedBox(height: 24),
        _RecentToolItem(
          title: 'Pro Tuner',
          subtitle: 'Chỉnh dây guitar',
          iconBgColor: Color.fromRGBO(249, 127, 6, 0.2),
          iconAsset: 'assets/icons/recent_tool_tuner.svg',
        ),
        SizedBox(height: 16),
        _RecentToolItem(
          title: 'Metronome',
          subtitle: 'Tùy chỉnh nhịp độ và phân nhịp',
          iconAsset: 'assets/icons/recent_tool_metronome_bg.svg',
        ),
      ],
    );
  }
}

class _RecentToolItem extends StatelessWidget {
  const _RecentToolItem({
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.iconBgColor,
  });

  final String title;
  final String subtitle;
  final String iconAsset;
  final Color? iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14.913),
      decoration: BoxDecoration(
        color: const Color(0xFF20201F),
        borderRadius: BorderRadius.circular(14.913),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 94.448,
            height: 69.593,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                width: 69.593,
                height: 69.593,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(9.942),
                ),
                alignment: Alignment.center,
                child: SizedBox(
                  width: 24.855,
                  height: 24.855,
                  child: _SafeSvgAsset(iconAsset),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 19.884,
                    fontWeight: FontWeight.w700,
                    height: 29.826 / 19.884,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    color: const Color.fromRGBO(255, 255, 255, 0.6),
                    fontSize: 14.913,
                    fontWeight: FontWeight.w400,
                    height: 19.884 / 14.913,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 7.664,
            height: 12.427,
            child: _SafeSvgAsset('assets/icons/recent_chevron.svg'),
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
        child: Icon(Icons.image_not_supported, size: 16, color: const Color(0xFF717171)),
      ),
    );
  }
}
