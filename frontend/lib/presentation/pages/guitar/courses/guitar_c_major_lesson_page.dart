import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class GuitarCMajorLessonPage extends StatefulWidget {
  const GuitarCMajorLessonPage({super.key});

  @override
  State<GuitarCMajorLessonPage> createState() => _GuitarCMajorLessonPageState();
}

class _GuitarCMajorLessonPageState extends State<GuitarCMajorLessonPage> {
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
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LessonTopBar(onBack: () => Navigator.of(context).maybePop()),
                  const SizedBox(height: 16),
                  const _VideoPlayerMock(),
                  const SizedBox(height: 24),
                  const _MetaHeader(),
                  const SizedBox(height: 24),
                  const _NoteTabs(),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8C00),
                        foregroundColor: const Color(0xFF4B2800),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(999),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 22),
                      ),
                      child: Text(
                        'ĐÁNH DẤU HOÀN THÀNH',
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          height: 24 / 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'BÀI HỌC TIẾP THEO',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFF8C00),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      height: 15 / 10,
                    ),
                  ),
                  const SizedBox(height: 14),
                  const _NextLessonCard(),
                  const SizedBox(height: 28),
                  Container(
                    width: double.infinity,
                    height: 1,
                    color: const Color.fromRGBO(68, 71, 78, 0.25),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'DANH SÁCH BÀI HỌC',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFC4C7CF),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      height: 15 / 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const _LessonListItem(
                    index: '01',
                    title: 'Bài 1: Làm quen với Guitar',
                    subtitle: '08:45 • Hoàn thành',
                    completed: true,
                  ),
                  const SizedBox(height: 8),
                  const _LessonListItem(
                    index: '02',
                    title: 'Bài 2: Tư thế cầm đàn',
                    subtitle: '10:20 • Hoàn thành',
                    completed: true,
                  ),
                  const SizedBox(height: 8),
                  const _LessonListItem(
                    index: '▶',
                    title: 'Bài 3: Hợp âm C trưởng',
                    subtitle: 'Đang học',
                    active: true,
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

class _LessonTopBar extends StatelessWidget {
  const _LessonTopBar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFF8C00),
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
          ),
          Expanded(
            child: Text(
              'Khóa học',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                height: 24 / 16,
              ),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFFF8C00), width: 1.2),
            ),
            child: const Icon(
              Icons.settings_outlined,
              color: Color(0xFFFF8C00),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoPlayerMock extends StatelessWidget {
  const _VideoPlayerMock();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        height: 220,
        decoration: BoxDecoration(
          color: const Color(0xFF101820),
          image: const DecorationImage(
            image: AssetImage('assets/images/guitar_course_hero.png'),
            fit: BoxFit.cover,
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(255, 140, 0, 0.06),
              blurRadius: 64,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromRGBO(0, 0, 0, 0.15),
                Color.fromRGBO(0, 0, 0, 0.75),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(0, 0, 0, 0.4),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 140, 0, 0.2),
                      ),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      '4K ULTRA HD',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFF8C00),
                        fontSize: 10,
                        letterSpacing: 1,
                        height: 16 / 10,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 140, 0, 0.24),
                    border: Border.all(color: const Color.fromRGBO(255, 140, 0, 0.4)),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    size: 36,
                    color: Color(0xFFFF8C00),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.15),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.33,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF8C00),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.replay_10, color: Colors.white70, size: 18),
                    const SizedBox(width: 12),
                    const Icon(Icons.pause, color: Colors.white70, size: 18),
                    const SizedBox(width: 12),
                    const Icon(Icons.forward_10, color: Colors.white70, size: 18),
                    const SizedBox(width: 14),
                    Text(
                      '04:20 / 12:45',
                      style: GoogleFonts.manrope(
                        color: const Color.fromRGBO(226, 226, 230, 0.75),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.volume_up_rounded, color: Colors.white70, size: 17),
                    const SizedBox(width: 12),
                    const Icon(Icons.settings, color: Colors.white70, size: 17),
                    const SizedBox(width: 12),
                    const Icon(Icons.fullscreen, color: Colors.white70, size: 17),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MetaHeader extends StatelessWidget {
  const _MetaHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: const Color.fromRGBO(255, 140, 0, 0.1),
                border: Border.all(color: const Color.fromRGBO(255, 140, 0, 0.2)),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'NGƯỜI HƯỚNG DẪN',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFFF8C00),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 2.5,
                  height: 15 / 10,
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.schedule_outlined, color: Color(0xFFC4C7CF), size: 14),
            const SizedBox(width: 4),
            Text(
              '12 phút',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFC4C7CF),
                fontSize: 14,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Text(
          'Bài 3: Hợp âm C trưởng',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFE2E2E6),
            fontSize: 36,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.8,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color.fromRGBO(255, 140, 0, 0.3), width: 2),
                shape: BoxShape.circle,
              ),
              child: ClipOval(
                child: Image.asset('assets/images/guitar_course_avatar.png', fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 14),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Khầy Hải',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE2E2E6),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 28 / 18,
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
        const SizedBox(height: 16),
        Text(
          'Trong bài này chúng ta sẽ học cách bấm hợp âm C trưởng đúng kỹ thuật và các lỗi thường gặp. Đây là một trong những hợp âm cơ bản nhất nhưng lại đòi hỏi sự khéo léo.',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFC4C7CF),
            fontSize: 18,
            height: 29 / 18,
          ),
        ),
      ],
    );
  }
}

class _NoteTabs extends StatelessWidget {
  const _NoteTabs();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Column(
              children: [
                Text(
                  'GHI CHÚ',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFF8C00),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 12),
                Container(width: 72, height: 2, color: const Color(0xFFFF8C00)),
              ],
            ),
            const SizedBox(width: 30),
            Text(
              'TÀI LIỆU',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFC4C7CF),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(30, 31, 34, 0.6),
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: const Color.fromRGBO(255, 140, 0, 0.1)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 140, 0, 0.1),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFFF8C00), size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mẹo nhỏ bài tập này:',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFE2E2E6),
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        height: 28 / 20,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _TipLine(text: 'Giữ ngón tay vuông góc với mặt phím.'),
                    const SizedBox(height: 10),
                    _TipLine(text: 'Không để lòng bàn tay chạm vào dây dưới.'),
                    const SizedBox(height: 10),
                    _TipLine(text: 'Kiểm tra từng dây một để đảm bảo tiếng vang.'),
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

class _TipLine extends StatelessWidget {
  const _TipLine({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFC4C7CF),
        fontSize: 16,
        fontWeight: FontWeight.w500,
        height: 24 / 16,
      ),
    );
  }
}

class _NextLessonCard extends StatelessWidget {
  const _NextLessonCard();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/guitar_toolkit_lesson_1.png',
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                right: 14,
                bottom: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(0, 0, 0, 0.8),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.12)),
                  ),
                  child: Text(
                    '15:30',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE2E2E6),
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Bài 4: Chuyển đổi giữa C và G',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFE2E2E6),
            fontSize: 20,
            fontWeight: FontWeight.w800,
            height: 25 / 20,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Kỹ thuật chuyển hợp âm mượt mà',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFC4C7CF),
            fontSize: 14,
            fontWeight: FontWeight.w500,
            height: 20 / 14,
          ),
        ),
      ],
    );
  }
}

class _LessonListItem extends StatelessWidget {
  const _LessonListItem({
    required this.index,
    required this.title,
    required this.subtitle,
    this.completed = false,
    this.active = false,
  });

  final String index;
  final String title;
  final String subtitle;
  final bool completed;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: active ? const Color.fromRGBO(255, 140, 0, 0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: active
            ? Border.all(color: const Color.fromRGBO(255, 140, 0, 0.2))
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: active ? const Color.fromRGBO(255, 140, 0, 0.2) : const Color(0xFF333538),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              index,
              style: GoogleFonts.manrope(
                color: active ? const Color(0xFFFF8C00) : const Color(0xFFC4C7CF),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: active ? const Color(0xFFFF8C00) : const Color(0xFFE2E2E6),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 24 / 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: active
                        ? const Color.fromRGBO(255, 140, 0, 0.7)
                        : const Color(0xFFC4C7CF),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                ),
              ],
            ),
          ),
          if (completed)
            const Icon(Icons.check_circle, color: Color(0xFFFF8C00), size: 20),
        ],
      ),
    );
  }
}
