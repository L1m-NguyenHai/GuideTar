import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/guitar/courses/guitar_c_major_lesson_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class GuitarCoursePage extends StatefulWidget {
  const GuitarCoursePage({super.key});

  @override
  State<GuitarCoursePage> createState() => _GuitarCoursePageState();
}

class _GuitarCoursePageState extends State<GuitarCoursePage> {
  int _selectedNavIndex = 1;

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
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  _TopBar(onBackTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(height: 18),
                  const _HeroSection(),
                  const SizedBox(height: 36),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 37),
                    child: const _CurriculumSection(),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 37),
                    child: const _InstructorCard(),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 37),
                    child: const _CourseStatsCard(),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackTap,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox(
                width: 32,
                height: 32,
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFFFF8C00),
                  size: 16,
                ),
              ),
            ),
            Expanded(
              child: Text(
                'Khóa học',
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFEAEAEA),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  height: 24 / 14,
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFFFF8C00), width: 1.2),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.settings_outlined,
                color: Color(0xFFFF8C00),
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroSection extends StatelessWidget {
  const _HeroSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(100),
        child: Container(
          width: double.infinity,
          constraints: const BoxConstraints(minHeight: 431),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: Stack(
            children: [
              Positioned.fill(
                child: Opacity(
                  opacity: 0.48,
                  child: Transform.scale(
                    scale: 1.12,
                    alignment: Alignment.centerRight,
                    child: Image.asset(
                      'assets/images/guitar_course_hero.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color(0xFF0E0E0E),
                        Color.fromRGBO(14, 14, 14, 0.0),
                      ],
                      stops: [0.0, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Color.fromRGBO(14, 14, 14, 0.6),
                        Color.fromRGBO(14, 14, 14, 0.0),
                      ],
                      stops: [0.35, 1.0],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(40, 48, 40, 48),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox.shrink(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(255, 140, 0, 0.1),
                            border: Border.all(
                              color: const Color.fromRGBO(255, 140, 0, 0.2),
                            ),
                            borderRadius: BorderRadius.circular(9999),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFFF8C00),
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Đang học',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFF8C00),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                  height: 15 / 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Guitar Cơ Bản -\nThầy Hải',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFEAEAEA),
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.9,
                            height: 45 / 36,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Tiến độ khóa học',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFADAAAA),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 1.2,
                                height: 16 / 12,
                              ),
                            ),
                            Text(
                              '35%',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFFF8C00),
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                height: 32 / 24,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(9999),
                          child: SizedBox(
                            height: 8,
                            child: Stack(
                              children: [
                                Container(color: const Color(0xFF2A2A29)),
                                FractionallySizedBox(
                                  widthFactor: 0.35,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFF8C00),
                                          Color(0xFFFD8B00),
                                        ],
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Color.fromRGBO(
                                            253,
                                            139,
                                            0,
                                            0.4,
                                          ),
                                          blurRadius: 15,
                                          offset: Offset.zero,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          width: 210,
                          height: 210,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color.fromRGBO(255, 255, 255, 0.35),
                              width: 2,
                            ),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/guitar_course_hero.png'),
                              fit: BoxFit.cover,
                            ),
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
      ),
    );
  }
}

class _CurriculumSection extends StatelessWidget {
  const _CurriculumSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Chương 1: Làm quen\nvới Guitar',
          badge: 'Sơ cấp',
          badgeColor: const Color(0xFFFF8C00),
        ),
        const SizedBox(height: 24),
        _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_1.png',
          title: 'Tư thế cầm đàn',
          subtitle: '10:00 • Tư thế cơ bản và sự thoải mái',
          active: false,
          completed: true,
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_2.png',
          title: 'Các dây đàn cơ bản',
          subtitle: '15:00 • Lên dây (E, A, D, G, B, E) và nhạc lý',
          active: false,
          completed: true,
        ),
        const SizedBox(height: 16),
        _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_3.png',
          title: 'Hợp âm C trưởng',
          subtitle: '12:45 • Vị trí đặt ngón tay cơ bản đầu tiên',
          active: true,
          completed: false,
          accent: true,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const GuitarCMajorLessonPage(),
              ),
            );
          },
        ),
        const SizedBox(height: 40),
        _SectionHeader(
          title: 'Chương 2: Nhịp\nphách',
          badge: 'Trung cấp',
          badgeColor: const Color(0xFFADAAAA),
          faded: true,
        ),
        const SizedBox(height: 24),
        _LockedLessonCard(
          title: 'Cách đếm nhịp 4/4',
          subtitle: '20:00 • Nền tảng về nhịp và phách',
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.badge,
    required this.badgeColor,
    this.faded = false,
  });

  final String title;
  final String badge;
  final Color badgeColor;
  final bool faded;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: faded ? 0.6 : 1,
      child: SizedBox(
        width: double.infinity,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Text(
                title,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFEAEAEA),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: Text(
                badge,
                style: GoogleFonts.plusJakartaSans(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  height: 15 / 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
    this.active = false,
    this.completed = false,
    this.accent = false,
    this.onTap,
  });

  final String imageAsset;
  final String title;
  final String subtitle;
  final bool active;
  final bool completed;
  final bool accent;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF20201F)
            : const Color.fromRGBO(26, 26, 26, 0.6),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(
          color: active
              ? const Color(0xFFFF8C00)
              : const Color.fromRGBO(253, 139, 0, 0.1),
          width: active ? 2 : 1,
        ),
        boxShadow: active
            ? const [
                BoxShadow(
                  color: Color.fromRGBO(253, 139, 0, 0.1),
                  blurRadius: 30,
                  offset: Offset.zero,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFFFF8C00)
                        : completed
                            ? const Color.fromRGBO(255, 140, 0, 0.2)
                            : const Color(0xFF2A2A29),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: SvgPicture.asset(
                    active
                        ? 'assets/icons/guitar_course_chevron.svg'
                        : completed
                            ? 'assets/icons/guitar_course_back.svg'
                            : 'assets/icons/guitar_course_arrow.svg',
                    width: active ? 11 : completed ? 20 : 16,
                    height: active ? 14 : completed ? 20 : 21,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFEAEAEA),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 24 / 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        subtitle,
                        style: GoogleFonts.plusJakartaSans(
                          color: accent
                              ? const Color(0xFFFF8C00)
                              : const Color(0xFFADAAAA),
                          fontSize: 14,
                          height: 20 / 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          if (active)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 140, 0, 0.1),
                borderRadius: BorderRadius.circular(9999),
              ),
              child: SizedBox(
                width: 7.4,
                height: 12,
                child: SvgPicture.asset('assets/icons/guitar_course_more.svg'),
              ),
            )
          else if (completed)
            SizedBox(
              width: 4,
              height: 16,
              child: SvgPicture.asset('assets/icons/guitar_course_progress.svg'),
            )
          else
            SizedBox(
              width: 16,
              height: 21,
              child: SvgPicture.asset('assets/icons/guitar_course_arrow.svg'),
            ),
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

class _LockedLessonCard extends StatelessWidget {
  const _LockedLessonCard({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(26, 26, 26, 0.6),
        borderRadius: BorderRadius.circular(9999),
        border: Border.all(color: const Color.fromRGBO(253, 139, 0, 0.1)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF2A2A29),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: SvgPicture.asset(
              'assets/icons/guitar_course_lock.svg',
              width: 16,
              height: 21,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFEAEAEA),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFADAAAA),
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 16,
            height: 16,
            child: SvgPicture.asset('assets/icons/guitar_course_lock.svg'),
          ),
        ],
      ),
    );
  }
}

class _InstructorCard extends StatelessWidget {
  const _InstructorCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(33),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(26, 26, 26, 0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color.fromRGBO(253, 139, 0, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Người hướng dẫn',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFFF8C00),
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2.5,
              height: 15 / 10,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(9999),
                    border: Border.all(
                      color: const Color.fromRGBO(255, 140, 0, 0.4),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      'assets/images/guitar_course_avatar.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Khầy Hải',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFEAEAEA),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 28 / 20,
                      ),
                    ),
                    Text(
                      'Nghệ sĩ Guitar • 15 năm',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFADAAAA),
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 23),
          Text(
            'Chuyên gia về guitar cổ điển (classical) và acoustic. Nổi tiếng với phương pháp chia nhỏ các nhịp điệu phức tạp thành những bước dễ tiếp thu, dễ hiểu.',
            style: GoogleFonts.plusJakartaSans(
              color: const Color.fromRGBO(234, 234, 234, 0.8),
              fontSize: 14,
              height: 22.75 / 14,
            ),
          ),
          const SizedBox(height: 22),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color.fromRGBO(255, 140, 0, 0.3)),
              borderRadius: BorderRadius.circular(9999),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
              child: Center(
                child: Text(
                  'Xem hồ sơ',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF8C00),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
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

class _CourseStatsCard extends StatelessWidget {
  const _CourseStatsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(47, 47, 47, 0.3),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color.fromRGBO(47, 47, 47, 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chi tiết khóa học',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFEAEAEA),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 28 / 20,
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Expanded(
                child: _CourseMetric(label: 'Bài học', value: '24 Bài'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _CourseMetric(label: 'Thời lượng', value: '8.5 Giờ'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          const Row(
            children: [
              Expanded(
                child: _CourseMetric(label: 'Học viên', value: '1.2k'),
              ),
              SizedBox(width: 16),
              Expanded(
                child: _CourseMetric(label: 'Đánh giá', value: '4.9 ★'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseMetric extends StatelessWidget {
  const _CourseMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFADAAAA),
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
            height: 15 / 11,
          ),
        ),
        const SizedBox(height: 7),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFEAEAEA),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 30 / 24,
          ),
        ),
      ],
    );
  }
}
