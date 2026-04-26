import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class PianoIntroDetailPage extends StatefulWidget {
  const PianoIntroDetailPage({super.key});

  @override
  State<PianoIntroDetailPage> createState() => _PianoIntroDetailPageState();
}

class _PianoIntroDetailPageState extends State<PianoIntroDetailPage> {
  int _selectedNavIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 126),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  _VideoHeaderSection(),
                  _CourseTitleSection(),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: _LessonsSection(),
                  ),
                  SizedBox(height: 28),
                  _GuidedSongsSection(),
                ],
              ),
            ),
            const _TopAppBar(),
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

class _VideoHeaderSection extends StatelessWidget {
  const _VideoHeaderSection();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 320,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/piano_course_detail_hero.png',
            fit: BoxFit.cover,
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(0, 0, 0, 0.6),
                  Color.fromRGBO(0, 0, 0, 0.0),
                  Color(0xFF0B0E14),
                ],
                stops: [0, 0.5, 1],
              ),
            ),
          ),
          Center(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(255, 159, 74, 0.2),
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF9F4A),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 22,
                      height: 28,
                      child: _SafeSvgAsset(
                        'assets/icons/piano_course_detail_play_hero.svg',
                      ),
                    ),
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

class _TopAppBar extends StatelessWidget {
  const _TopAppBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 104,
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  alignment: Alignment.center,
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: _SafeSvgAsset(
                      'assets/icons/piano_course_detail_back.svg',
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Người mới bắt đầu',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFECEDF6),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.45,
                  height: 28 / 18,
                ),
              ),
            ],
          ),
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: SizedBox(
              width: 4,
              height: 16,
              child: _SafeSvgAsset('assets/icons/piano_course_detail_more.svg'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTitleSection extends StatelessWidget {
  const _CourseTitleSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2028),
              borderRadius: BorderRadius.circular(9999),
              border: Border.all(color: const Color.fromRGBO(69, 72, 79, 0.15)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF7FE6DB),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  'NGƯỜI MỚI BẮT ĐẦU',
                  style: GoogleFonts.inter(
                    color: const Color(0xFF7FE6DB),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Giới thiệu về piano',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFECEDF6),
              fontSize: 30,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.75,
              height: 36 / 30,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(bottom: 20, top: 4),
            child: Row(
              children: const [
                _MetaInfoItem(
                  iconAsset: 'assets/icons/piano_course_detail_lessons.svg',
                  text: '12 Bài học',
                ),
                SizedBox(width: 24),
                _MetaInfoItem(
                  iconAsset: 'assets/icons/piano_course_detail_songs.svg',
                  text: '4 Bài hát',
                ),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: const Color(0xFFFF9F4A),
                foregroundColor: const Color(0xFF532A00),
                minimumSize: const Size(double.infinity, 56),
                shape: const StadiumBorder(),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                'Bắt đầu bài học',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF532A00),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 24 / 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaInfoItem extends StatelessWidget {
  const _MetaInfoItem({required this.iconAsset, required this.text});

  final String iconAsset;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 18.33, height: 15, child: _SafeSvgAsset(iconAsset)),
        const SizedBox(width: 8),
        Text(
          text,
          style: GoogleFonts.inter(
            color: const Color(0xFFA9ABB3),
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 24 / 16,
          ),
        ),
      ],
    );
  }
}

class _LessonsSection extends StatelessWidget {
  const _LessonsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Bài học',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFECEDF6),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
              ),
            ),
            Text(
              'Hoàn thành 14%',
              style: GoogleFonts.inter(
                color: const Color(0xFFA9ABB3),
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          thumbAsset: 'assets/images/piano_course_detail_lesson_1.png',
          title: '1. Pitch and the\nPiano',
          subtitle: '8:45 • Các khái niệm cơ bản',
          iconAsset: 'assets/icons/piano_course_detail_badge_unlocked.svg',
          unlocked: true,
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          thumbAsset: 'assets/images/piano_course_detail_lesson_2.png',
          title: '2. The Staff',
          subtitle: '12:20 • Trực quan hoá',
          iconAsset: 'assets/icons/piano_course_detail_lock.svg',
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          thumbAsset: 'assets/images/piano_course_detail_lesson_3.png',
          title: '3. Rhythms and\nClefs',
          subtitle: '15:10 • Kí hiệu thời gian',
          iconAsset: 'assets/icons/piano_course_detail_lock.svg',
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.thumbAsset,
    required this.title,
    required this.subtitle,
    required this.iconAsset,
    this.unlocked = false,
  });

  final String thumbAsset;
  final String title;
  final String subtitle;
  final String iconAsset;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final Color bg = unlocked
        ? const Color(0xFF10131A)
        : const Color.fromRGBO(16, 19, 26, 0.5);
    final Color titleColor = unlocked
        ? const Color(0xFFECEDF6)
        : const Color.fromRGBO(236, 237, 246, 0.6);
    final Color subColor = unlocked
        ? const Color(0xFFA9ABB3)
        : const Color.fromRGBO(169, 171, 179, 0.6);

    return Opacity(
      opacity: unlocked ? 1 : 0.8,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 96,
                height: 64,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ColorFiltered(
                      colorFilter: unlocked
                          ? const ColorFilter.mode(
                              Colors.transparent,
                              BlendMode.dst,
                            )
                          : const ColorFilter.mode(
                              Color.fromRGBO(255, 255, 255, 0.35),
                              BlendMode.saturation,
                            ),
                      child: Image.asset(thumbAsset, fit: BoxFit.cover),
                    ),
                    if (unlocked)
                      Container(
                        color: const Color.fromRGBO(0, 0, 0, 0.2),
                        alignment: Alignment.center,
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: _SafeSvgAsset(
                            'assets/icons/piano_course_detail_play_lesson.svg',
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.plusJakartaSans(
                      color: titleColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 24 / 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      color: subColor,
                      fontSize: 12,
                      height: 16 / 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(width: 28, height: 21, child: _SafeSvgAsset(iconAsset)),
          ],
        ),
      ),
    );
  }
}

class _GuidedSongsSection extends StatelessWidget {
  const _GuidedSongsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hướng dẫn bài hát',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFECEDF6),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 28 / 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Rèn luyện kĩ năng của bạn qua các bài hát đơn giản',
                style: GoogleFonts.inter(
                  color: const Color(0xFFA9ABB3),
                  fontSize: 14,
                  height: 20 / 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 216,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            children: const [
              _SongCard(
                imageAsset: 'assets/images/piano_course_detail_song_1.png',
                title: "Brahms' Lullaby",
                subtitle: 'Classical • Johannes Brahms',
              ),
              SizedBox(width: 24),
              _SongCard(
                imageAsset: 'assets/images/piano_course_detail_song_2.png',
                title: 'La Cucaracha',
                subtitle: 'Folk • Traditional',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SongCard extends StatelessWidget {
  const _SongCard({
    required this.imageAsset,
    required this.title,
    required this.subtitle,
  });

  final String imageAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 256,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: 144,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(imageAsset, fit: BoxFit.cover),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: const EdgeInsets.only(right: 12, bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color.fromRGBO(0, 0, 0, 0.6),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'GRADE 1',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          height: 15 / 10,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFECEDF6),
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 24 / 16,
            ),
          ),
          const SizedBox(height: 0),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              color: const Color(0xFFA9ABB3),
              fontSize: 14,
              height: 20 / 14,
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
