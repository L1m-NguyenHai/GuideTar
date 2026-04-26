import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/piano/courses/piano_intro_detail_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class PianoBasicCoursesPage extends StatefulWidget {
  const PianoBasicCoursesPage({super.key});

  @override
  State<PianoBasicCoursesPage> createState() => _PianoBasicCoursesPageState();
}

class _PianoBasicCoursesPageState extends State<PianoBasicCoursesPage> {
  int _selectedNavIndex = 1;

  void _openIntroCourseDetail() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PianoIntroDetailPage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 64, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  const _CourseSectionHeader(
                    title: 'Người mới bắt đầu',
                    actionText: 'Xem tất cả',
                  ),
                  SizedBox(height: 16),
                  _BeginnerCoursesCarousel(onIntroTap: _openIntroCourseDetail),
                  SizedBox(height: 40),
                  const _CourseSectionHeader(
                    title: 'Trình độ trung cấp',
                    actionText: 'Xem tất cả',
                  ),
                  SizedBox(height: 16),
                  const _IntermediateSection(),
                  SizedBox(height: 40),
                  const _CourseSectionHeader(
                    title: 'Hợp âm',
                    actionText: 'Xem tất cả',
                  ),
                  SizedBox(height: 16),
                  const _ChordsCarousel(),
                  SizedBox(height: 40),
                  const _TechniquesSection(),
                ],
              ),
            ),
            const _TopBar(),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: HomeBottomNavbar(
                  selectedIndex: _selectedNavIndex,
                  onChanged: (index) {
                    if (index == 0) {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                      return;
                    }
                    setState(() {
                      _selectedNavIndex = index;
                    });
                  },
                ),
              ),
            ),
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
    return Container(
      height: 64,
      color: const Color(0xFF0B0E14),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 40,
              height: 40,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _SafeSvgAsset('assets/icons/piano_courses_back.svg'),
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Piano cơ bản',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFECEDF6),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 28 / 20,
              ),
            ),
          ),
          SizedBox(
            width: 40,
            height: 40,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: _SafeSvgAsset('assets/icons/piano_courses_more.svg'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseSectionHeader extends StatelessWidget {
  const _CourseSectionHeader({required this.title, required this.actionText});

  final String title;
  final String actionText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFECEDF6),
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
              height: 32 / 24,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          actionText,
          style: GoogleFonts.inter(
            color: const Color(0xFFF97316),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _BeginnerCoursesCarousel extends StatelessWidget {
  const _BeginnerCoursesCarousel({required this.onIntroTap});

  final VoidCallback onIntroTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CourseCard(
            imageAsset: 'assets/images/piano_courses_beginner_1.png',
            level: 'LEVEL 1',
            title: 'Giới thiệu về piano',
            lessons: '12 bài học',
            duration: '45 phút',
            onTap: onIntroTap,
          ),
          const SizedBox(width: 20),
          const _CourseCard(
            imageAsset: 'assets/images/piano_courses_beginner_2.png',
            level: 'LEVEL 2',
            title: 'Chơi các bài hát đơn',
            lessons: '8 bài học',
            duration: '32 phút',
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({
    required this.imageAsset,
    required this.level,
    required this.title,
    required this.lessons,
    required this.duration,
    this.onTap,
  });

  final String imageAsset;
  final String level;
  final String title;
  final String lessons;
  final String duration;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget content = SizedBox(
      width: 288,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              height: 180,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imageAsset, fit: BoxFit.cover),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.fromRGBO(11, 14, 20, 0.0),
                          Color.fromRGBO(11, 14, 20, 0.8),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(255, 159, 74, 0.2),
                        borderRadius: BorderRadius.circular(9999),
                      ),
                      child: Text(
                        level,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF9F4A),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                          height: 15 / 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 11),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFECEDF6),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 22.5 / 18,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                lessons,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA9ABB3),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Color(0xFF45484F),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                duration,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA9ABB3),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );

    if (onTap == null) {
      return content;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}

class _IntermediateSection extends StatelessWidget {
  const _IntermediateSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 227,
          decoration: BoxDecoration(
            color: const Color(0xFF10131A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 7,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'CHUỖI BÀI NÂNG CAO',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFFF9F4A),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          height: 16 / 12,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Intermediate\nPiano Playing',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFECEDF6),
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          height: 27.5 / 20,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Thành thạo các nhịp điệu và cấu trúc hoà âm phổ biến.',
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA9ABB3),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF97316),
                          borderRadius: BorderRadius.circular(9999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tiếp tục',
                              style: GoogleFonts.inter(
                                color: const Color(0xFF532A00),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 7,
                              height: 8,
                              child: _SafeSvgAsset(
                                'assets/icons/piano_courses_arrow.svg',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                    right: Radius.circular(12),
                  ),
                  child: Image.asset(
                    'assets/images/piano_courses_intermediate_hero.png',
                    fit: BoxFit.cover,
                    height: double.infinity,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          height: 112,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF161A21),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 80,
                  height: 80,
                  child: Image.asset(
                    'assets/images/piano_courses_intermediate_thumb.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Pedal tạo tiếng vang',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFECEDF6),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Kĩ thuật tạo cảm xúc',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA9ABB3),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: 0.35,
                              minHeight: 4,
                              backgroundColor: const Color(0xFF22262F),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF9F4A),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '35%',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFA9ABB3),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            height: 15 / 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChordsCarousel extends StatelessWidget {
  const _ChordsCarousel();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: const [
          _CourseCard(
            imageAsset: 'assets/images/piano_courses_beginner_1.png',
            level: 'LEVEL 1',
            title: 'Giới thiệu hợp âm',
            lessons: '12 bài học',
            duration: '45 phút',
          ),
          SizedBox(width: 20),
          _CourseCard(
            imageAsset: 'assets/images/piano_courses_beginner_2.png',
            level: 'LEVEL 2',
            title: 'Chơi hợp âm cơ bản',
            lessons: '8 bài học',
            duration: '32 phút',
          ),
        ],
      ),
    );
  }
}

class _TechniquesSection extends StatelessWidget {
  const _TechniquesSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kĩ thuật và Luyện tập',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFECEDF6),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            height: 32 / 24,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.0,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: const [
            _ExerciseItem(
              iconAsset: 'assets/icons/piano_courses_speed.svg',
              iconBg: Color.fromRGBO(127, 230, 219, 0.1),
              title: 'Tăng tốc độ',
              subtitle: '15 PHÚT',
            ),
            _ExerciseItem(
              iconAsset: 'assets/icons/piano_courses_finger.svg',
              iconBg: Color.fromRGBO(255, 159, 74, 0.1),
              title: 'Luyện ngón',
              subtitle: '10 PHÚT',
            ),
            _ExerciseItem(
              iconAsset: 'assets/icons/piano_courses_chord.svg',
              iconBg: Color.fromRGBO(255, 159, 74, 0.1),
              title: 'Hợp âm',
              subtitle: '12 PHÚT',
            ),
            _ExerciseItem(
              iconAsset: 'assets/icons/piano_courses_improv.svg',
              iconBg: Color.fromRGBO(127, 230, 219, 0.1),
              title: 'Ứng tấu',
              subtitle: '20 PHÚT',
            ),
          ],
        ),
      ],
    );
  }
}

class _ExerciseItem extends StatelessWidget {
  const _ExerciseItem({
    required this.iconAsset,
    required this.iconBg,
    required this.title,
    required this.subtitle,
  });

  final String iconAsset;
  final Color iconBg;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF161A21),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 20,
              child: _SafeSvgAsset(iconAsset),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFECEDF6),
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 20 / 14,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: const Color(0xFFA9ABB3),
              fontSize: 10,
              letterSpacing: -0.5,
              height: 15 / 10,
            ),
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
