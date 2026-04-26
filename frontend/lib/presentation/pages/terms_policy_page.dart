import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class TermsPolicyPage extends StatefulWidget {
  const TermsPolicyPage({super.key});

  @override
  State<TermsPolicyPage> createState() => _TermsPolicyPageState();
}

class _TermsPolicyPageState extends State<TermsPolicyPage> {
  int _selectedNavIndex = 2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(30, 96, 30, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Chúng tôi cam kết bảo vệ dữ liệu và quyền lợi\ncủa bạn khi trải nghiệm trên nền tảng.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFADAAAA),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      height: 1.62,
                    ),
                  ),
                  const SizedBox(height: 22),
                  _LegalCard(
                    title: 'Chi tiết điều khoản',
                    updated: 'CẬP NHẬT: 05/04/2026',
                    sections: const [
                      _LegalSection(
                        title: '1. Chấp thuận các Điều khoản',
                        body:
                            'Bằng việc tạo tài khoản và sử dụng Guidetar, bạn đồng ý tuân thủ các quy định của chúng tôi. Nếu không đồng ý, vui lòng ngừng sử dụng dịch vụ.',
                      ),
                      _LegalSection(
                        title: '2. Quyền Sở hữu Trí tuệ',
                        body:
                            'Toàn bộ nội dung trên nền tảng (âm nhạc, lời bài hát, hình ảnh, giao diện) thuộc bản quyền của Guidetar và đối tác. Nghiêm cấm mọi hành vi sao chép, phân phối hoặc trục lợi trái phép.',
                      ),
                      _LegalSection(
                        title: '3. Trách nhiệm Người dùng',
                        body:
                            'Bạn tự chịu trách nhiệm bảo mật thông tin đăng nhập của mình. Không sử dụng ứng dụng để thực hiện các hành vi vi phạm pháp luật, phát tán mã độc hoặc gây rối loạn hệ thống.',
                      ),
                      _LegalSection(
                        title: '4. Sửa đổi Điều khoản',
                        body:
                            'Guidetar có quyền cập nhật điều khoản bất kỳ lúc nào. Việc bạn tiếp tục sử dụng ứng dụng sau khi cập nhật đồng nghĩa với việc bạn chấp thuận các thay đổi đó.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _LegalCard(
                    title: 'Chi tiết chính sách',
                    updated: 'CẬP NHẬT: 05/04/2026',
                    darkLevel: 0.72,
                    sections: const [
                      _LegalSection(
                        title: '1. Thu thập Dữ liệu',
                        body:
                            'Chúng tôi chỉ thu thập các thông tin cơ bản (tên, email) và lịch sử nghe nhạc nhằm mục đích cá nhân hóa trải nghiệm và đề xuất các bài hát phù hợp với sở thích của bạn.',
                      ),
                      _LegalSection(
                        title: '2. Bảo mật Dữ liệu',
                        body:
                            'Guidetar áp dụng các biện pháp bảo mật và mã hóa tiên tiến nhất để bảo vệ thông tin cá nhân của bạn khỏi việc truy cập trái phép.',
                      ),
                      _LegalSection(
                        title: '3. Chia sẻ Thông tin',
                        body:
                            'Chúng tôi cam kết không bán hoặc trao đổi dữ liệu cá nhân của bạn cho bên thứ ba vì mục đích thương mại. Thông tin chỉ được cung cấp khi có yêu cầu hợp lệ từ cơ quan pháp luật.',
                      ),
                      _LegalSection(
                        title: '4. Quyền của Người dùng',
                        body:
                            'Bạn có toàn quyền truy cập, chỉnh sửa thông tin cá nhân, tài khoản trên hệ thống của Guidetar bất cứ lúc nào.',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: _TopBar(onBackTap: () => Navigator.of(context).maybePop()),
          ),
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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.70)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: onBackTap,
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFDF7100),
              size: 17,
            ),
          ),
          Expanded(
            child: Text(
              'Điều khoản & Chính sách',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Container(
            width: 30,
            height: 30,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDF7100), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFDF7100),
              size: 17,
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalCard extends StatelessWidget {
  const _LegalCard({
    required this.title,
    required this.updated,
    required this.sections,
    this.darkLevel = 0.76,
  });

  final String title;
  final String updated;
  final List<_LegalSection> sections;
  final double darkLevel;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Color.fromRGBO(5, 5, 5, darkLevel),
        borderRadius: BorderRadius.circular(32),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(25, 25, 25, 22),
        decoration: BoxDecoration(
          color: const Color.fromRGBO(14, 14, 14, 0.54),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              updated,
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 10,
                letterSpacing: 1,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 12),
            for (var i = 0; i < sections.length; i++) ...[
              Text(
                sections[i].title,
                style: GoogleFonts.manrope(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  height: 1.56,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                sections[i].body,
                style: GoogleFonts.manrope(
                  color: const Color(0xFFADAAAA),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  height: 1.62,
                ),
              ),
              if (i != sections.length - 1) const SizedBox(height: 18),
            ],
          ],
        ),
      ),
    );
  }
}

class _LegalSection {
  const _LegalSection({required this.title, required this.body});

  final String title;
  final String body;
}
