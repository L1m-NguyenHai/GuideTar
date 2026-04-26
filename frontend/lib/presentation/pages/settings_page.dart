import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/login_page.dart';
import 'package:guidetar/presentation/pages/membership_page.dart';
import 'package:guidetar/presentation/pages/terms_policy_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  int _selectedNavIndex = 2;
  bool _notificationOn = true;
  _AppLanguage _language = _AppLanguage.english;

  Future<void> _showLanguagePopup() async {
    _AppLanguage tempSelection = _language;

    final result = await showGeneralDialog<_AppLanguage>(
      context: context,
      barrierLabel: 'language-popup',
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.45),
      pageBuilder: (_, _, _) => const SizedBox.shrink(),
      transitionBuilder: (context, animation, _, _) {
        final t = Curves.easeOutCubic.transform(animation.value);
        return Opacity(
          opacity: animation.value,
          child: Transform.scale(
            scale: 0.92 + (0.08 * t),
            child: StatefulBuilder(
              builder: (context, setPopupState) {
                final isViUi = _language == _AppLanguage.vietnamese;
                final title = isViUi ? 'Chọn ngôn ngữ' : 'Select Language';
                final applyLabel = isViUi ? 'Áp dụng' : 'Apply';
                final viLabel = isViUi ? 'Tiếng Việt' : 'Vietnamese';
                final enLabel = isViUi ? 'Tiếng Anh' : 'English';

                Widget languageOption({
                  required _AppLanguage value,
                  required String label,
                  required String flag,
                }) {
                  final selected = tempSelection == value;
                  return InkWell(
                    onTap: () => setPopupState(() => tempSelection = value),
                    borderRadius: BorderRadius.circular(32),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: selected
                            ? const Color.fromRGBO(255, 159, 74, 0.10)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: selected
                              ? const Color.fromRGBO(255, 159, 74, 0.22)
                              : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color.fromRGBO(0, 0, 0, 0.25),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              flag,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              label,
                              style: GoogleFonts.plusJakartaSans(
                                color: selected
                                    ? const Color(0xFFFF9F4A)
                                    : const Color(0xFFADAAAA),
                                fontSize: 16,
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: selected
                                    ? const Color(0xFFFF9F4A)
                                    : const Color(0xFF484847),
                                width: 2,
                              ),
                            ),
                            child: selected
                                ? Center(
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFFFF9F4A),
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Center(
                  child: Material(
                    color: Colors.transparent,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 360),
                          margin: const EdgeInsets.symmetric(horizontal: 20),
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: const Color.fromRGBO(32, 32, 31, 0.90),
                            borderRadius: BorderRadius.circular(32),
                            border: Border.all(
                              color: const Color.fromRGBO(72, 72, 71, 0.10),
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.50),
                                blurRadius: 50,
                                offset: Offset(0, 20),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: GoogleFonts.plusJakartaSans(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.6,
                                ),
                              ),
                              const SizedBox(height: 24),
                              languageOption(
                                value: _AppLanguage.vietnamese,
                                label: viLabel,
                                flag: '🇻🇳',
                              ),
                              const SizedBox(height: 8),
                              languageOption(
                                value: _AppLanguage.english,
                                label: enLabel,
                                flag: '🇺🇸',
                              ),
                              const SizedBox(height: 15),
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFFFF9F4A), Color(0xFFFD8B00)],
                                    ),
                                    borderRadius: BorderRadius.circular(999),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Color.fromRGBO(255, 159, 74, 0.25),
                                        blurRadius: 16,
                                        offset: Offset(0, 8),
                                      ),
                                    ],
                                  ),
                                  child: TextButton(
                                    onPressed: () => Navigator.of(context).pop(tempSelection),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(999),
                                      ),
                                    ),
                                    child: Text(
                                      applyLabel,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFF532A00),
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) {
      return;
    }
    setState(() {
      _language = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(26, 80, 26, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SectionTitle('TÀI KHOẢN'),
                  const SizedBox(height: 16),
                  _GroupCard(
                    children: [
                      _SettingTile(
                        icon: Icons.workspace_premium_outlined,
                        title: 'Gói thành viên',
                        showDivider: false,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MembershipPage(),
                            ),
                          );
                        },
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF353534),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color.fromRGBO(255, 183, 127, 0.2),
                                ),
                              ),
                              child: Text(
                                'MIỄN PHÍ',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFFFFB77F),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                  height: 15 / 10,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFDDC1AE),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('CÀI ĐẶT CHUNG'),
                  const SizedBox(height: 16),
                  _GroupCard(
                    children: [
                      _SettingTile(
                        icon: Icons.language,
                        title: 'Ngôn ngữ',
                        onTap: _showLanguagePopup,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _language.displayName,
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFDDC1AE),
                                fontSize: 14,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFDDC1AE),
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                      _SettingTile(
                        icon: Icons.notifications_none,
                        title: 'Thông báo',
                        trailing: Switch(
                          value: _notificationOn,
                          activeThumbColor: const Color(0xFFE5E2E1),
                          activeTrackColor: const Color(0xFFFF8A00),
                          inactiveThumbColor: const Color(0xFFE5E2E1),
                          inactiveTrackColor: const Color(0xFF3A3939),
                          onChanged: (v) => setState(() => _notificationOn = v),
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('NHẠC CỤ & LUYỆN TẬP'),
                  const SizedBox(height: 16),
                  _GroupCard(
                    children: [
                      _SettingTile(
                        icon: Icons.library_music_outlined,
                        title: 'Nhạc cụ mặc định',
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Guitar',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFDDC1AE),
                                fontSize: 14,
                                height: 20 / 14,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right,
                              color: Color(0xFFDDC1AE),
                              size: 16,
                            ),
                          ],
                        ),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const _SectionTitle('THÔNG TIN'),
                  const SizedBox(height: 16),
                  _GroupCard(
                    children: [
                      _SettingTile(
                        icon: Icons.description_outlined,
                        title: 'Điều khoản & Chính sách',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const TermsPolicyPage(),
                            ),
                          );
                        },
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Color(0xFFDDC1AE),
                          size: 16,
                        ),
                      ),
                      const _SettingTile(
                        icon: Icons.info_outline,
                        title: 'Phiên bản ứng dụng',
                        trailing: _VersionTag('v1.0.2'),
                        showDivider: false,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                        (route) => false,
                      );
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 17),
                      decoration: BoxDecoration(
                        color: const Color(0xFF201F1F),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color.fromRGBO(255, 180, 171, 0.1),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.logout,
                            color: Color(0xFFFF8A00),
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Đăng xuất',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFFF8A00),
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              height: 24 / 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            _TopBar(onBackTap: () => Navigator.of(context).maybePop()),
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
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.7)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Cài đặt',
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
                height: 24 / 16,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(Icons.more_horiz, color: Colors.white, size: 20),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFC8C6C5),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 2.4,
        height: 16 / 12,
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF201F1F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.trailing,
    this.showDivider = true,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final Widget trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: BoxDecoration(
            border: showDivider
                ? const Border(
                    bottom: BorderSide(color: Color.fromRGBO(19, 19, 19, 0.1)),
                  )
                : null,
          ),
          child: Row(
            children: [
              Icon(icon, size: 20, color: const Color(0xFFE5E2E1)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE5E2E1),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    height: 24 / 16,
                  ),
                ),
              ),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class _VersionTag extends StatelessWidget {
  const _VersionTag(this.value);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFDDC1AE),
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 20 / 14,
      ),
    );
  }
}

enum _AppLanguage {
  vietnamese,
  english;

  String get displayName {
    switch (this) {
      case _AppLanguage.vietnamese:
        return 'Tiếng Việt';
      case _AppLanguage.english:
        return 'Tiếng Anh';
    }
  }
}
