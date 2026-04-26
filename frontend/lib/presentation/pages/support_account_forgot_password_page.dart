import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SupportAccountForgotPasswordPage extends StatefulWidget {
  const SupportAccountForgotPasswordPage({super.key});

  @override
  State<SupportAccountForgotPasswordPage> createState() =>
      _SupportAccountForgotPasswordPageState();
}

class _SupportAccountForgotPasswordPageState
    extends State<SupportAccountForgotPasswordPage> {
  int _selectedNavIndex = 2;

  static const _steps = <_StepItem>[
    _StepItem(
      title: 'Bước 1',
      desc: 'Nhấn vào "Quên mật khẩu" ngay tại màn hình đăng nhập.',
      icon: Icons.lock_outline_rounded,
      iconBg: Color.fromRGBO(255, 142, 36, 0.12),
      iconColor: Color(0xFFEF8D2A),
    ),
    _StepItem(
      title: 'Bước 2',
      desc: 'Nhập địa chỉ email mà bạn đã dùng để đăng ký tài khoản.',
      icon: Icons.mail_outline_rounded,
      iconBg: Color.fromRGBO(255, 142, 36, 0.12),
      iconColor: Color(0xFFEF8D2A),
    ),
    _StepItem(
      title: 'Bước 3',
      desc: 'Kiểm tra hộp thư đến và nhấn vào liên kết thiết lập lại.',
      icon: Icons.mark_email_read_outlined,
      iconBg: Color.fromRGBO(255, 142, 36, 0.12),
      iconColor: Color(0xFFEF8D2A),
    ),
    _StepItem(
      title: 'Bước 4',
      desc: 'Tạo một mật khẩu mới mạnh mẽ và bảo mật hơn.',
      icon: Icons.shield_outlined,
      iconBg: Color.fromRGBO(255, 142, 36, 0.12),
      iconColor: Color(0xFFEF8D2A),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF0E0E0E), Color(0xFF070707)],
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 88, 26, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HƯỚNG DẪN',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFDF7100),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Cách khôi phục mật\nkhẩu đã quên?',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF4F4F5),
                      fontSize: 50 * 0.8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1,
                      height: 1.05,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Đừng lo lắng! Chỉ với vài bước đơn giản,\nchúng tôi sẽ giúp bạn truy cập lại tài\nkhoản của mình một cách an toàn và\nnhanh chóng.',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFB7B4AF),
                      fontSize: 31 * 0.45,
                      fontWeight: FontWeight.w500,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 22),
                  for (var i = 0; i < _steps.length; i++) ...[
                    _StepCard(item: _steps[i]),
                    if (i != _steps.length - 1) const SizedBox(height: 24),
                  ],
                  const SizedBox(height: 22),
                  _BottomIllustration(),
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

class _StepCard extends StatelessWidget {
  const _StepCard({required this.item});

  final _StepItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 220),
      padding: const EdgeInsets.fromLTRB(33, 33, 24, 33),
      decoration: BoxDecoration(
        color: const Color(0xFF20201F),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 22),
          ),
          const SizedBox(height: 14),
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 28 * 0.8,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            item.desc,
            style: GoogleFonts.manrope(
              color: const Color(0xFFAAA7A3),
              fontSize: 15,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 192,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromRGBO(99, 99, 99, 0.12), Color.fromRGBO(20, 20, 20, 0.48)],
        ),
      ),
      child: Center(
        child: Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color.fromRGBO(255, 255, 255, 0.08),
            border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.2)),
          ),
          child: const Icon(Icons.lock, color: Color(0xFFD4D7DC), size: 38),
        ),
      ),
    );
  }
}

class _StepItem {
  const _StepItem({
    required this.title,
    required this.desc,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
  });

  final String title;
  final String desc;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
}
