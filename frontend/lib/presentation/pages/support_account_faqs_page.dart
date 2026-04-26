import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/support_account_forgot_password_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SupportAccountFaqsPage extends StatefulWidget {
  const SupportAccountFaqsPage({super.key});

  @override
  State<SupportAccountFaqsPage> createState() => _SupportAccountFaqsPageState();
}

class _SupportAccountFaqsPageState extends State<SupportAccountFaqsPage> {
  int _selectedNavIndex = 2;

  static const _items = <_FaqSummaryItem>[
    _FaqSummaryItem(
      question: 'Cách khôi phục mật khẩu đã\nquên?',
      subtitle: 'Hướng dẫn từng bước để khôi phục tài\nkhoản',
      height: 150,
    ),
    _FaqSummaryItem(
      question: 'Cách thay đổi email tài\nkhoản?',
      subtitle: 'Cập nhật địa chỉ liên hệ chính của bạn',
      height: 130,
    ),
    _FaqSummaryItem(
      question: 'Thiết lập xác thực hai yếu tố',
      subtitle: 'Tăng cường bảo mật của bạn bằng\n2FA',
      height: 122,
    ),
    _FaqSummaryItem(
      question: 'Làm cách nào để xác minh\nemail tài khoản của tôi?',
      subtitle: 'Giải thích quy trình xác nhận',
      height: 142,
    ),
    _FaqSummaryItem(
      question: 'Tôi có thể liên kết nhiều\nthiết bị không?',
      subtitle: 'Giới hạn sử dụng và quản lý thiết bị',
      height: 130,
    ),
    _FaqSummaryItem(
      question: 'Quản lý các gói đăng ký\ncao cấp',
      subtitle: 'Thanh toán, các hạng và tính năng',
      height: 130,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 88, 28, 132),
              child: Column(
                children: [
                  for (var i = 0; i < _items.length; i++) ...[
                    _AccountFaqCard(
                      item: _items[i],
                      onTap: i == 0
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const SupportAccountForgotPasswordPage(),
                                ),
                              );
                            }
                          : null,
                    ),
                    if (i != _items.length - 1) const SizedBox(height: 16),
                  ],
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
              'Tài Khoản FAQs',
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

class _AccountFaqCard extends StatelessWidget {
  const _AccountFaqCard({required this.item, this.onTap});

  final _FaqSummaryItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: item.height),
          padding: const EdgeInsets.fromLTRB(25, 25, 18, 25),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF20201F),
            border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.16)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      item.question,
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 25 * 0.8,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item.subtitle,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFF9F9C98),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFE5E2E1),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaqSummaryItem {
  const _FaqSummaryItem({
    required this.question,
    required this.subtitle,
    required this.height,
  });

  final String question;
  final String subtitle;
  final double height;
}
