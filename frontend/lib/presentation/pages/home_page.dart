import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/auth_session.dart';
import 'package:guidetar/presentation/pages/guitar/tools/guitar_toolkit_page.dart';
import 'package:guidetar/presentation/pages/piano/tools/piano_toolkit_page.dart';
import 'package:guidetar/presentation/pages/profile_page.dart';
import 'package:guidetar/presentation/pages/recent_page.dart';
import 'package:guidetar/presentation/pages/settings_page.dart';
import 'package:guidetar/presentation/pages/support_page.dart';
import 'package:guidetar/presentation/pages/login_page.dart';
import 'package:guidetar/presentation/widgets/app_sidebar_panel.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedNavIndex = 0;
  bool _isSidebarOpen = false;
  static const double _openedMainTranslateX = 162;
  static const double _openedMainTranslateY = 138;
  static const double _openedMainScale = 0.79;

  void _closeSidebar() {
    if (_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = false;
      });
    }
  }

  void _openSidebar() {
    if (!_isSidebarOpen) {
      setState(() {
        _isSidebarOpen = true;
      });
    }
  }

  void _openProfile() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
  }

  void _openRecent() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RecentPage()));
  }

  void _openSettings() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  void _openSupport() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportPage()));
  }

  void _logout() {
    AuthSession.clear();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: _isSidebarOpen ? null : const Color(0xFF0E0E0E),
              gradient: _isSidebarOpen
                  ? const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0xFFD0988F), Color(0xFF6A4D49)],
                    )
                  : null,
            ),
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            top: 0,
            bottom: 0,
            left: _isSidebarOpen ? 22 : -280,
            child: AppSidebarPanel(
              onClose: _closeSidebar,
              items: [
                SidebarMenuItem(
                  label: 'Trang chủ',
                  icon: Icons.home_outlined,
                  active: true,
                  onTap: _closeSidebar,
                ),
                SidebarMenuItem(
                  label: 'Khoá học',
                  icon: Icons.menu_book_outlined,
                  onTap: () {
                    _closeSidebar();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuitarToolkitPage(),
                      ),
                    );
                  },
                ),
                SidebarMenuItem(
                  label: 'Hỗ trợ',
                  icon: Icons.headset_mic_outlined,
                  onTap: () {
                    _closeSidebar();
                    _openSupport();
                  },
                ),
                SidebarMenuItem(
                  label: 'Cài đặt',
                  icon: Icons.settings_outlined,
                  onTap: () {
                    _closeSidebar();
                    _openSettings();
                  },
                ),
                SidebarMenuItem(
                  label: 'Đăng xuất',
                  icon: Icons.logout,
                  onTap: _logout,
                ),
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 320),
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translateByDouble(
                _isSidebarOpen ? _openedMainTranslateX : 0.0,
                _isSidebarOpen ? _openedMainTranslateY : 0.0,
                0,
                1,
              )
              ..scaleByDouble(
                _isSidebarOpen ? _openedMainScale : 1.0,
                _isSidebarOpen ? _openedMainScale : 1.0,
                1,
                1,
              ),
            transformAlignment: Alignment.topLeft,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isSidebarOpen ? 24 : 0),
              child: Container(
                color: const Color(0xFF0E0E0E),
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16, 80, 16, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _EditorialHeader(),
                          const SizedBox(height: 16),
                          _MainCardsGrid(
                            onOpenGuitarToolkit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const GuitarToolkitPage(),
                                ),
                              );
                            },
                            onOpenPianoToolkit: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const PianoToolkitPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          const _ComingSoonSection(),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _TopBar(
                        onMenuTap: _openSidebar,
                        onProfileTap: _openProfile,
                      ),
                    ),
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Center(
                        child: HomeBottomNavbar(
                          selectedIndex: _selectedNavIndex,
                          onChanged: (index) {
                            if (index == 2) {
                              _openProfile();
                              return;
                            }
                            if (index == 3) {
                              _openRecent();
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
            ),
          ),
          if (_isSidebarOpen)
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeSidebar,
              ),
            ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap, required this.onProfileTap});

  final VoidCallback onMenuTap;
  final VoidCallback onProfileTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(9, 9, 11, 0.6),
        border: Border(
          bottom: BorderSide(color: const Color.fromRGBO(72, 72, 71, 0.1)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: onMenuTap,
            behavior: HitTestBehavior.opaque,
            child: SizedBox(
              width: 24,
              height: 24,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                child: SvgPicture.asset('assets/icons/menu.svg'),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 18,
                child: SvgPicture.asset('assets/icons/logo_note_top.svg'),
              ),
              const SizedBox(width: 8),
              Text(
                'GuideTar',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF4F4F5),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  height: 28 / 18,
                  letterSpacing: -0.9,
                ),
              ),
            ],
          ),
          GestureDetector(
            onTap: onProfileTap,
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF262626),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(
                  color: const Color.fromRGBO(72, 72, 71, 0.2),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Image.asset(
                'assets/images/user_profile.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditorialHeader extends StatelessWidget {
  const _EditorialHeader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 118,
      child: Stack(
        children: [
          Positioned(
            left: -8,
            child: Text(
              'KHỞI ĐẦU LỘ TRÌNH',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFF923E),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                height: 15 / 10,
              ),
            ),
          ),
          Positioned(
            top: 22,
            left: 0,
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.75,
                  height: 37.5 / 30,
                ),
                children: const [
                  TextSpan(text: 'Chọn'),
                  TextSpan(
                    text: ' nhạc cụ',
                    style: TextStyle(color: Color(0xFFFF923E)),
                  ),
                  TextSpan(text: ' của bạn'),
                ],
              ),
            ),
          ),
          Positioned(
            top: 71.38,
            left: 0,
            child: Text(
              'Chọn con đường chinh phục sự tinh thông.\nLộ trình được thiết kế để từng bước nâng tầm kỹ năng.',
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 14,
                height: 22.75 / 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MainCardsGrid extends StatelessWidget {
  const _MainCardsGrid({this.onOpenGuitarToolkit, this.onOpenPianoToolkit});

  final VoidCallback? onOpenGuitarToolkit;
  final VoidCallback? onOpenPianoToolkit;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _InstrumentCard(
            imageAsset: 'assets/images/guitar_card.png',
            tagText: 'PHỔ BIẾN',
            tagBg: Color(0xFFFF923E),
            tagColor: Colors.black,
            title: 'Guitar',
            description: 'làm chủ những dây đàn với điệu Blue,...',
            buttonText: 'bắt đầu',
            buttonBg: Color(0xFFFF923E),
            buttonTextColor: Color(0xFF4D2300),
            arrowAsset: 'assets/icons/arrow_right_small.svg',
            onButtonTap: onOpenGuitarToolkit,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _InstrumentCard(
            imageAsset: 'assets/images/piano_card.png',
            tagText: 'CỔ ĐIỂN',
            tagBg: Color(0xFFFFD262),
            tagColor: Color(0xFF543F00),
            title: 'Piano',
            description: 'Khai mở phím đàn với\nnhạc lý,...',
            buttonText: 'Chọn',
            buttonBg: Color(0xFF262626),
            buttonTextColor: Colors.white,
            buttonBorder: Color.fromRGBO(72, 72, 71, 0.3),
            arrowAsset: 'assets/icons/arrow_right_light.svg',
            onButtonTap: onOpenPianoToolkit,
          ),
        ),
      ],
    );
  }
}

class _InstrumentCard extends StatelessWidget {
  const _InstrumentCard({
    required this.imageAsset,
    required this.tagText,
    required this.tagBg,
    required this.tagColor,
    required this.title,
    required this.description,
    required this.buttonText,
    required this.buttonBg,
    required this.buttonTextColor,
    required this.arrowAsset,
    this.onButtonTap,
    this.buttonBorder,
  });

  final String imageAsset;
  final String tagText;
  final Color tagBg;
  final Color tagColor;
  final String title;
  final String description;
  final String buttonText;
  final Color buttonBg;
  final Color buttonTextColor;
  final String arrowAsset;
  final VoidCallback? onButtonTap;
  final Color? buttonBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 320,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.6,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color.fromRGBO(0, 0, 0, 0.2),
                    Colors.black,
                  ],
                  stops: const [0, 0.5, 1],
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: tagBg,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    tagText,
                    style: GoogleFonts.manrope(
                      color: tagColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                      height: 12 / 8,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 24,
                    height: 32 / 24,
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
                    height: 16 / 12,
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: onButtonTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: buttonBg,
                      borderRadius: BorderRadius.circular(999),
                      border: buttonBorder == null
                          ? null
                          : Border.all(color: buttonBorder!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          buttonText,
                          style: GoogleFonts.playwriteUsTrad(
                            color: buttonTextColor,
                            fontSize: 12,
                            height: 16 / 12,
                          ),
                        ),
                        const SizedBox(width: 4),
                        SizedBox(
                          width: 9.33,
                          height: 9.33,
                          child: SvgPicture.asset(arrowAsset),
                        ),
                      ],
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

class _ComingSoonSection extends StatelessWidget {
  const _ComingSoonSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'MỞ RỘNG THÊM CÁC NHẠC CỤ TRONG TƯƠNG LAI',
          style: GoogleFonts.manrope(
            color: const Color(0xFF767575),
            fontWeight: FontWeight.w700,
            fontSize: 10,
            letterSpacing: 1,
            height: 15 / 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Coming Soon',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 20,
            height: 28 / 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 24),
        GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: const [
            _SoonCard(
              iconAsset: 'assets/icons/drums.svg',
              title: 'TRỐNG',
              subtitle: 'Q4 2026',
            ),
            _SoonCard(
              iconAsset: 'assets/icons/violin.svg',
              title: 'VIOLIN',
              subtitle: 'Winter 2027',
            ),
            _SoonCard(
              iconAsset: 'assets/icons/bass.svg',
              title: 'BASS',
              subtitle: 'Spring 2027',
            ),
            _RequestCard(),
          ],
        ),
      ],
    );
  }
}

class _SoonCard extends StatelessWidget {
  const _SoonCard({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
  });

  final String iconAsset;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.1)),
      ),
      child: Opacity(
        opacity: 0.7,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                color: Color(0xFF262626),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 22,
                height: 22,
                child: SvgPicture.asset(iconAsset),
              ),
            ),
            const SizedBox(height: 9),
            Text(
              title,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFADAAAA),
                fontWeight: FontWeight.w700,
                fontSize: 14,
                letterSpacing: -0.35,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: GoogleFonts.manrope(
                color: const Color(0xFF767575),
                fontWeight: FontWeight.w700,
                fontSize: 9,
                height: 13.5 / 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color.fromRGBO(72, 72, 71, 0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF484847),
                style: BorderStyle.solid,
              ),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 11.67,
              height: 11.67,
              child: SvgPicture.asset('assets/icons/plus.svg'),
            ),
          ),
          const SizedBox(height: 9),
          Text(
            'YÊU CẦU',
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: -0.35,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Vote Next',
            style: GoogleFonts.manrope(
              color: const Color(0xFFADAAAA),
              fontWeight: FontWeight.w700,
              fontSize: 9,
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
