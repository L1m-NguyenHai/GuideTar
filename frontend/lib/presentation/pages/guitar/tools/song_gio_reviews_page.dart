import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/guitar/tools/song_gio_comment_thread_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SongGioReviewsPage extends StatefulWidget {
  const SongGioReviewsPage({super.key});

  @override
  State<SongGioReviewsPage> createState() => _SongGioReviewsPageState();
}

class _SongGioReviewsPageState extends State<SongGioReviewsPage> {
  int _selectedNavIndex = 1;
  int _myRating = 4;

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
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 116),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TopBar(onBackTap: () => Navigator.of(context).maybePop()),
                  const SizedBox(height: 16),
                  const _SongInfoCard(),
                  const SizedBox(height: 14),
                  const _RatingSummarySection(),
                  const SizedBox(height: 18),
                  Text(
                    'Chia sẻ trải nghiệm của bạn',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE2E2E6),
                      fontSize: 30 / 2,
                      fontWeight: FontWeight.w700,
                      height: 36 / 30,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            for (int i = 1; i <= 5; i++)
                              IconButton(
                                onPressed: () => setState(() => _myRating = i),
                                iconSize: 32,
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints.tightFor(
                                  width: 40,
                                  height: 40,
                                ),
                                icon: Icon(
                                  i <= _myRating ? Icons.star_rounded : Icons.star_border_rounded,
                                  color: const Color(0xFFFFA14A),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 72,
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F1F1F),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Viết gì đó cũng được',
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF646464),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFA14A),
                              foregroundColor: const Color(0xFF3D2306),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              elevation: 0,
                            ),
                            child: Text(
                              'Gửi đánh giá',
                              style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                height: 24 / 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ReviewCard(
                    avatar: 'assets/images/guitar_toolkit_user_profile.png',
                    name: 'Minh Tú',
                    time: '2h trước',
                    content:
                        'Bảng hợp âm chia rất chuẩn xác, các vị trí chuyển hợp âm đã đúng nhịp bài hát. Tính năng đổi tone và tự động cuộn thực sự rất tiện lợi khi vừa đàn vừa hát. Đánh giá 5 sao!',
                    likes: 128,
                    comments: 14,
                    onReplyTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SongGioCommentThreadPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _ReviewCard(
                    avatar: 'assets/images/profile_user_avatar.png',
                    name: 'Quoc Huy',
                    time: '5h trước',
                    content:
                        'Cách sắp xếp hợp âm [Am], [Em7] ở đoạn Verse nghe rất bắt tai và chuẩn với giai điệu. Giao diện tối giúp nhìn lâu không bị mỏi mắt khi tập đàn.',
                    likes: 85,
                    comments: 4,
                    onReplyTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SongGioCommentThreadPage(),
                        ),
                      );
                    },
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
    return Row(
      children: [
        GestureDetector(
          onTap: onBackTap,
          behavior: HitTestBehavior.opaque,
          child: const SizedBox(
            width: 28,
            height: 28,
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFF9F4A),
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            'Đánh giá & Bình luận',
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
        const SizedBox(
          width: 28,
          height: 28,
          child: Icon(
            Icons.account_circle_outlined,
            color: Color(0xFFFF9F4A),
            size: 20,
          ),
        ),
      ],
    );
  }
}

class _SongInfoCard extends StatelessWidget {
  const _SongInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/chord_reco_song_gio.png',
              width: 80,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sóng gió',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    height: 25 / 20,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'K-ICM, JACK',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    height: 20 / 14,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    SizedBox(
                      width: 13,
                      height: 13,
                      child: SvgPicture.asset('assets/icons/songgio_rating_star.svg'),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '4.5',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 20 / 14,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '(585)',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFADAAAA),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RatingSummarySection extends StatelessWidget {
  const _RatingSummarySection();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Container(
            height: 147,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '4.5',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2.4,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 12),
                    Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 12),
                    Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 12),
                    Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 12),
                    Icon(Icons.star_border_rounded, color: Color(0xFFFF9F4A), size: 12),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'GLOBAL RATING',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                    height: 15 / 10,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 7,
          child: Container(
            height: 147,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RatingBarLine(label: '5★', ratio: 0.8),
                SizedBox(height: 8),
                _RatingBarLine(label: '4★', ratio: 0.65),
                SizedBox(height: 8),
                _RatingBarLine(label: '3★', ratio: 0.3),
                SizedBox(height: 8),
                _RatingBarLine(label: '2★', ratio: 0.12),
                SizedBox(height: 8),
                _RatingBarLine(label: '1★', ratio: 0.08),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingBarLine extends StatelessWidget {
  const _RatingBarLine({required this.label, required this.ratio});

  final String label;
  final double ratio;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          child: Text(
            label,
            style: GoogleFonts.splineSans(
              color: const Color(0xFFADAAAA),
              fontSize: 10,
              fontWeight: FontWeight.w500,
              height: 15 / 10,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: SizedBox(
              height: 6,
              child: Stack(
                children: [
                  Container(color: const Color(0xFF262626)),
                  FractionallySizedBox(
                    widthFactor: ratio,
                    child: Container(color: const Color(0xFFFF9F4A)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({
    required this.avatar,
    required this.name,
    required this.time,
    required this.content,
    required this.likes,
    required this.comments,
    this.onReplyTap,
  });

  final String avatar;
  final String name;
  final String time;
  final String content;
  final int likes;
  final int comments;
  final VoidCallback? onReplyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF141414),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.asset(
                  avatar,
                  width: 32,
                  height: 32,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFE2E2E6),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 16 / 12,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 10),
                        Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 10),
                        Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 10),
                        Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 10),
                        Icon(Icons.star_rounded, color: Color(0xFFFF9F4A), size: 10),
                      ],
                    ),
                  ],
                ),
              ),
              Text(
                time,
                style: GoogleFonts.manrope(
                  color: const Color(0xFF707070),
                  fontSize: 9,
                  height: 15 / 9,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFB5B5B8),
              fontSize: 14,
              height: 21 / 14,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(Icons.thumb_up_alt_outlined, color: Color(0xFF7A7A7A), size: 16),
              const SizedBox(width: 4),
              Text(
                '$likes',
                style: GoogleFonts.manrope(
                  color: const Color(0xFF8A8A8A),
                  fontSize: 13,
                  height: 20 / 13,
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: onReplyTap,
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    const Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: Color(0xFF7A7A7A),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Phản hồi',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF8A8A8A),
                        fontSize: 13,
                        height: 20 / 13,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '$comments',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF8A8A8A),
                        fontSize: 13,
                        height: 20 / 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
