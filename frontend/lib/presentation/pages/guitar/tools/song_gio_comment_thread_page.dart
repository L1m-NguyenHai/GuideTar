import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SongGioCommentThreadPage extends StatelessWidget {
  const SongGioCommentThreadPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 122),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    height: 64,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    color: const Color(0xFF131313),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          behavior: HitTestBehavior.opaque,
                          child: const SizedBox(
                            width: 16,
                            height: 16,
                            child: Icon(
                              Icons.arrow_back_ios_new_rounded,
                              color: Color(0xFFE5E2E1),
                              size: 16,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Bình luận',
                          style: GoogleFonts.manrope(
                            color: const Color(0xFFE5E2E1),
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.45,
                            height: 28 / 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 15),
                  const _MainCommentCard(),
                  const SizedBox(height: 12),
                  const SizedBox(
                    width: 326,
                    child: Column(
                      children: [
                        _ReplyCard(
                          avatar: 'assets/images/profile_user_avatar.png',
                          name: 'Duy Anh',
                          time: '1 ngày trước',
                          content:
                              'Cảm ơn bác, đúng là phần điệp khúc hay thật! Mình loay hoay mãi đoạn đó.',
                          likesText: '4',
                        ),
                        SizedBox(height: 8),
                        _ReplyCard(
                          avatar: 'assets/images/guitar_toolkit_user_profile.png',
                          name: 'Bco Nam',
                          time: 'Vừa xong',
                          content:
                              'Hợp âm bài này đánh tone gì vậy ạ? Em thấy kẹp capo ngăn 3 nghe ổn hơn.',
                          likesText: 'Like',
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
              child: Container(
                decoration: const BoxDecoration(
                  color: Color.fromRGBO(53, 53, 52, 0.7),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color.fromRGBO(0, 0, 0, 0.4),
                      blurRadius: 32,
                      offset: Offset(0, -4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1C1B1B),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Viết bình luận...',
                            style: GoogleFonts.manrope(
                              color: const Color.fromRGBO(182, 181, 180, 0.6),
                              fontSize: 14,
                              height: 20 / 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFFB77F), Color(0xFFFF8A00)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Icon(Icons.send_rounded, color: Color(0xFF2E1A06), size: 20),
                      ),
                    ],
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

class _MainCommentCard extends StatelessWidget {
  const _MainCommentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(86, 67, 52, 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Image.asset(
                  'assets/images/guitar_toolkit_user_profile.png',
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Minh Tu',
                          style: GoogleFonts.splineSans(
                            color: const Color(0xFFE5E2E1),
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.4,
                            height: 24 / 16,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '2 NGÀY TRƯỚC',
                          style: GoogleFonts.splineSans(
                            color: const Color(0xFFB6B5B4),
                            fontSize: 10,
                            letterSpacing: 1,
                            height: 15 / 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: const [
                        Icon(Icons.star_rounded, color: Color(0xFFFFB77F), size: 12),
                        Icon(Icons.star_rounded, color: Color(0xFFFFB77F), size: 12),
                        Icon(Icons.star_rounded, color: Color(0xFFFFB77F), size: 12),
                        Icon(Icons.star_rounded, color: Color(0xFFFFB77F), size: 12),
                        Icon(Icons.star_rounded, color: Color(0xFFFFB77F), size: 12),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Bản hợp âm chia rất chuẩn xác, đặc biệt là phần chuyển tone ở cuối bài. Rất hữu ích cho những người mới tập guitar như mình.',
                      style: GoogleFonts.splineSans(
                        color: const Color(0xFFE5E2E1),
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        height: 24.38 / 15,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.thumb_up_alt_rounded, color: Color(0xFFDDC1AE), size: 17),
                        const SizedBox(width: 8),
                        Text(
                          '24',
                          style: GoogleFonts.inter(
                            color: const Color(0xFFDDC1AE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                          ),
                        ),
                        const SizedBox(width: 24),
                        const Icon(Icons.chat_bubble_outline_rounded, color: Color(0xFFDDC1AE), size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Phản hồi',
                          style: GoogleFonts.splineSans(
                            color: const Color(0xFFDDC1AE),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            height: 20 / 14,
                          ),
                        ),
                      ],
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

class _ReplyCard extends StatelessWidget {
  const _ReplyCard({
    required this.avatar,
    required this.name,
    required this.time,
    required this.content,
    required this.likesText,
  });

  final String avatar;
  final String name;
  final String time;
  final String content;
  final String likesText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 16, 16, 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(16),
          bottomRight: Radius.circular(16),
          bottomLeft: Radius.circular(16),
        ),
        border: const Border(
          left: BorderSide(color: Color.fromRGBO(255, 183, 127, 0.2), width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Image.asset(avatar, width: 32, height: 32, fit: BoxFit.cover),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.splineSans(
                        color: const Color(0xFFE5E2E1),
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        height: 20 / 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      time,
                      style: GoogleFonts.splineSans(
                        color: const Color(0xFFB6B5B4),
                        fontSize: 9,
                        height: 13.5 / 9,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: GoogleFonts.splineSans(
                    color: const Color.fromRGBO(229, 226, 225, 0.9),
                    fontSize: 14,
                    height: 21 / 14,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.thumb_up_alt_outlined, color: Color(0xFFDDC1AE), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      likesText,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFDDC1AE),
                        fontSize: 12,
                        height: 16 / 12,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      'Phản hồi',
                      style: GoogleFonts.splineSans(
                        color: const Color(0xFFDDC1AE),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
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
