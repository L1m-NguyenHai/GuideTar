import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/guitar/tools/chord_book_page.dart';
import 'package:guidetar/presentation/pages/guitar/tools/dechord_page.dart';
import 'package:guidetar/presentation/pages/guitar/tools/guitar_ear_training_page.dart';
import 'package:guidetar/presentation/pages/guitar/tools/metronome_page.dart';
import 'package:guidetar/presentation/pages/guitar/courses/guitar_course_page.dart';
import 'package:guidetar/presentation/pages/guitar/tools/pro_tuner_page.dart';
import 'package:guidetar/presentation/pages/login_page.dart';
import 'package:guidetar/presentation/pages/settings_page.dart';
import 'package:guidetar/presentation/pages/support_page.dart';
import 'package:guidetar/presentation/widgets/app_sidebar_panel.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class GuitarToolkitPage extends StatefulWidget {
  const GuitarToolkitPage({super.key});

  @override
  State<GuitarToolkitPage> createState() => _GuitarToolkitPageState();
}

class _GuitarToolkitPageState extends State<GuitarToolkitPage> {
  bool _gridMode = true;
  int _selectedNavIndex = 1;
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

  void _openProTuner() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ProTunerPage()));
  }

  void _openChordBook() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ChordBookPage()));
  }

  void _openDeChord() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const DeChordPage()));
  }

  void _openGuitarCourse() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuitarCoursePage()));
  }

  void _openEarTraining() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const GuitarEarTrainingPage()));
  }

  void _openSettings() {
    _closeSidebar();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SettingsPage()));
  }

  void _openSupport() {
    _closeSidebar();
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportPage()));
  }

  void _logout() {
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
                  onTap: () {
                    _closeSidebar();
                    if (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
                SidebarMenuItem(
                  label: 'Khoá học',
                  icon: Icons.menu_book_outlined,
                  onTap: () {
                    _closeSidebar();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GuitarCoursePage(),
                      ),
                    );
                  },
                ),
                SidebarMenuItem(
                  label: 'Hỗ trợ',
                  icon: Icons.headset_mic_outlined,
                  onTap: _openSupport,
                ),
                SidebarMenuItem(
                  label: 'Cài đặt',
                  icon: Icons.settings_outlined,
                  onTap: _openSettings,
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
                      padding: const EdgeInsets.fromLTRB(24, 83, 24, 132),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bộ công cụ Guitar',
                            style: GoogleFonts.plusJakartaSans(
                              color: Colors.white,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.9,
                              height: 40 / 36,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Chọn một trong số các công cụ',
                            style: GoogleFonts.playwriteUsTrad(
                              color: const Color(0xFFADAAAA),
                              fontSize: 16,
                              height: 24 / 16,
                            ),
                          ),
                          const SizedBox(height: 22),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final toggle = Container(
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF131313),
                                  borderRadius: BorderRadius.circular(999),
                                  border: Border.all(
                                    color: const Color.fromRGBO(
                                      72,
                                      72,
                                      71,
                                      0.1,
                                    ),
                                  ),
                                ),
                                clipBehavior: Clip.antiAlias,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _ModeButton(
                                      text: 'Dạng lưới',
                                      selected: _gridMode,
                                      onTap: () {
                                        setState(() => _gridMode = true);
                                      },
                                    ),
                                    _ModeButton(
                                      text: 'Danh sách',
                                      selected: !_gridMode,
                                      onTap: () {
                                        setState(() => _gridMode = false);
                                      },
                                    ),
                                  ],
                                ),
                              );

                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Công cụ chính',
                                      style: GoogleFonts.plusJakartaSans(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        height: 28 / 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: toggle,
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(height: 16),
                          _ToolsSection(
                            gridMode: _gridMode,
                            onProTunerTap: _openProTuner,
                            onChordBookTap: _openChordBook,
                            onDeChordTap: _openDeChord,
                            onEarTrainingTap: _openEarTraining,
                          ),
                          const SizedBox(height: 32),
                          _LessonSection(onFirstLessonTap: _openGuitarCourse),
                          const SizedBox(height: 22),
                          const _SpotlightSection(),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: _TopBar(onMenuTap: _openSidebar),
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
                              if (Navigator.of(context).canPop()) {
                                Navigator.of(context).pop();
                              }
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
              child: Row(
                children: [
                  const SizedBox(width: 294),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: _closeSidebar,
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.onMenuTap});

  final VoidCallback onMenuTap;

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
                child: _SafeSvgAsset(
                  'assets/icons/guitar_toolkit_menu.svg',
                  fallbackIcon: Icons.menu,
                ),
              ),
            ),
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 18,
                child: _SafeSvgAsset(
                  'assets/icons/guitar_toolkit_logo_note.svg',
                  fallbackIcon: Icons.music_note,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'GuideTar',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF4F4F5),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  letterSpacing: -0.9,
                  height: 28 / 18,
                ),
              ),
            ],
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: const Color(0xFF262626),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.2)),
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/images/guitar_toolkit_user_profile.png',
              fit: BoxFit.cover,
              errorBuilder: (_, error, stackTrace) =>
                  const Icon(Icons.person, color: Color(0xFFADAAAA), size: 16),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  const _ModeButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF923E) : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected
                ? const Color.fromRGBO(255, 191, 132, 0.45)
                : Colors.transparent,
            width: 0.8,
          ),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color.fromRGBO(255, 146, 62, 0.12),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Text(
          text,
          style: GoogleFonts.manrope(
            color: selected ? const Color(0xFF4D2300) : const Color(0xFF717171),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            height: 16 / 12,
          ),
        ),
      ),
    );
  }
}

class _ToolsSection extends StatelessWidget {
  const _ToolsSection({
    required this.gridMode,
    required this.onProTunerTap,
    required this.onChordBookTap,
    required this.onDeChordTap,
    required this.onEarTrainingTap,
  });

  final bool gridMode;
  final VoidCallback onProTunerTap;
  final VoidCallback onChordBookTap;
  final VoidCallback onDeChordTap;
  final VoidCallback onEarTrainingTap;

  @override
  Widget build(BuildContext context) {
    final tools = <_ToolItem>[
      const _ToolItem(
        title: 'Pro Tuner',
        description: 'Chỉnh dây guitar',
        iconAsset: 'assets/icons/guitar_toolkit_icon_tuner.svg',
        iconTint: Color(0xFFFF923E),
        iconBackground: Color.fromRGBO(255, 146, 62, 0.1),
        opensProTuner: true,
      ),
      const _ToolItem(
        title: 'Hợp âm juẩn',
        description: 'Hợp âm các bài hát do cộng đồng đăng tải',
        iconAsset: 'assets/icons/guitar_toolkit_icon_chordbook.svg',
        iconTint: Color(0xFFFFD262),
        iconBackground: Color.fromRGBO(255, 210, 98, 0.1),
        opensChordBook: true,
      ),
      const _ToolItem(
        title: 'AI DeChord',
        description: 'Sử dụng sức mạnh của AI để tìm hợp âm cho bài hát',
        iconAsset: 'assets/icons/guitar_toolkit_icon_ai.svg',
        iconTint: Color(0xFFFF923E),
        iconBackground: Color.fromRGBO(255, 210, 98, 0.1),
        opensDeChord: true,
      ),
      const _ToolItem(
        title: 'Metronome',
        description: 'Đơn giản mà một cái metronome đầy đủ tính năng',
        iconAsset: 'assets/icons/guitar_toolkit_icon_metronome_bg.svg',
        opensMetronome: true,
      ),
      const _ToolItem(
        title: 'Luyện cảm âm',
        description: 'Luyện cảm âm, trưởng thứ, âm giai',
        iconAsset: 'assets/icons/guitar_toolkit_icon_ear_training_bg.svg',
        opensEarTraining: true,
      ),
    ];
    final listModeTools = <_ToolItem>[
      tools[0],
      tools[1],
      tools[3],
      tools[2],
      tools[4],
    ];

    if (!gridMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (int i = 0; i < listModeTools.length; i++) ...[
            _ToolListItem(
              item: listModeTools[i],
              onTap: listModeTools[i].opensProTuner
                  ? onProTunerTap
                  : (listModeTools[i].opensChordBook
                        ? onChordBookTap
                        : (listModeTools[i].opensDeChord
                              ? onDeChordTap
                              : (listModeTools[i].opensEarTraining
                                ? onEarTrainingTap
                                : (listModeTools[i].opensMetronome
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) => const MetronomePage(),
                                        ),
                                      );
                                    }
                                  : null)))),
            ),
            if (i != listModeTools.length - 1) const SizedBox(height: 12),
          ],
        ],
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = (constraints.maxWidth - 16) / 2;
        return Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            for (final tool in tools)
              SizedBox(
                width: itemWidth,
                child: _ToolCard(
                  item: tool,
                  onTap: tool.opensProTuner
                      ? onProTunerTap
                      : (tool.opensChordBook
                            ? onChordBookTap
                            : (tool.opensDeChord
                                  ? onDeChordTap
                                  : (tool.opensEarTraining
                                        ? onEarTrainingTap
                                        : (tool.opensMetronome
                                          ? () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute(
                                                  builder: (_) => const MetronomePage(),
                                                ),
                                              );
                                            }
                                          : null)))),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ToolListItem extends StatelessWidget {
  const _ToolListItem({required this.item, this.onTap});

  final _ToolItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    Color iconBg;
    if (item.title == 'Pro Tuner') {
      iconBg = const Color(0x33F97F06);
    } else if (item.title == 'AI DeChord') {
      iconBg = const Color(0xFF4C331A);
    } else {
      iconBg = const Color(0x1AFFFFFF);
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF20201F),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(5),
              ),
              alignment: Alignment.center,
              child: SizedBox(
                width: 14,
                height: 14,
                child: _SafeSvgAsset(item.iconAsset),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      height: 15 / 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.description,
                    style: GoogleFonts.manrope(
                      color: const Color(0x99FFFFFF),
                      fontSize: 9,
                      height: 12 / 9,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, size: 12, color: Color(0xFFADAAAA)),
          ],
        ),
      ),
    );
  }
}

class _ToolItem {
  const _ToolItem({
    required this.title,
    required this.description,
    required this.iconAsset,
    this.iconTint,
    this.iconBackground,
    this.opensProTuner = false,
    this.opensChordBook = false,
    this.opensDeChord = false,
    this.opensEarTraining = false,
    this.opensMetronome = false,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Color? iconTint;
  final Color? iconBackground;
  final bool opensProTuner;
  final bool opensChordBook;
  final bool opensDeChord;
  final bool opensEarTraining;
  final bool opensMetronome;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item, this.onTap});

  final _ToolItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: const BoxConstraints(minHeight: 220),
        padding: const EdgeInsets.all(25),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.1)),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color.fromRGBO(38, 38, 38, 0.4),
              Color.fromRGBO(26, 26, 26, 0.6),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToolIcon(item: item),
            const SizedBox(height: 13),
            Text(
              item.title,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 18,
                height: 28 / 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.description,
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 12,
                height: 19.5 / 12,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.item});

  final _ToolItem item;

  @override
  Widget build(BuildContext context) {
    if (item.iconBackground == null) {
      return SizedBox(
        width: 48,
        height: 48,
        child: _SafeSvgAsset(item.iconAsset),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: item.iconBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: SizedBox(
        width: 24,
        height: 24,
        child: _SafeSvgAsset(item.iconAsset),
      ),
    );
  }
}

class _LessonSection extends StatelessWidget {
  const _LessonSection({required this.onFirstLessonTap});

  final VoidCallback onFirstLessonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'CÁC BÀI HỌC',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFFF923E),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.4,
                  height: 20 / 14,
                ),
              ),
            ),
            Text(
              'XEM TẤT CẢ',
              style: GoogleFonts.manrope(
                color: const Color(0xFFADAAAA),
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 15 / 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_1.png',
          category: 'GUITAR CƠ BẢN',
          categoryColor: Color(0xFFFFD262),
          title: 'Thầy Hải',
          subtitle: 'Thuần học vẹt',
          onTap: onFirstLessonTap,
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_2.png',
          category: 'CẢM ÂM CƠ BẢN',
          categoryColor: Color(0xFFFFD262),
          title: 'Thầy De-Hair',
          subtitle: 'Cảm âm',
        ),
        const SizedBox(height: 16),
        const _LessonCard(
          imageAsset: 'assets/images/guitar_toolkit_lesson_3.png',
          category: 'ĐỆM HÁT NÂNG CAO',
          categoryColor: Color(0xFFFF923E),
          title: 'Backing Track, Passing Chord,... với thầy Hair',
          subtitle:
              'Các kĩ thuật nâng cao trong đệm hát, chuyển tông, passing chord, hợp âm màu',
        ),
      ],
    );
  }
}

class _LessonCard extends StatelessWidget {
  const _LessonCard({
    required this.imageAsset,
    required this.category,
    required this.categoryColor,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final String imageAsset;
  final String category;
  final Color categoryColor;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: const Color(0xFF131313),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.05)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 80,
              height: 80,
              child: Image.asset(
                imageAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, error, stackTrace) => Container(
                  color: const Color(0xFF1C1C1C),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Color(0xFF717171),
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  category,
                  style: GoogleFonts.manrope(
                    color: categoryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                    height: 15 / 10,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  title,
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 12,
                    height: 16 / 12,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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

class _SpotlightSection extends StatelessWidget {
  const _SpotlightSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(33, 41, 33, 33),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: const Color.fromRGBO(249, 115, 22, 0.1)),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromRGBO(249, 115, 22, 0.2),
            Color.fromRGBO(249, 115, 22, 0.0),
          ],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -34,
            bottom: -38,
            child: SizedBox(
              width: 110,
              height: 110,
              child: _SafeSvgAsset(
                'assets/icons/guitar_toolkit_icon_decor_star.svg',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Đã đến lúc toả sáng',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 24 / 24,
                ),
              ),
              const SizedBox(height: 19),
              SizedBox(
                width: 200,
                child: Text(
                  'chỉ còn 3 buổi tập nữa là bạn sẽ hoàn thành thử thách “Lãng tử Guitar” tuần này”',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFADAAAA),
                    fontSize: 14,
                    height: 20 / 14,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF923E),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  'Start Learning',
                  style: GoogleFonts.manrope(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    height: 20 / 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SafeSvgAsset extends StatelessWidget {
  const _SafeSvgAsset(
    this.assetPath, {
    this.fallbackIcon = Icons.image_not_supported,
  });

  final String assetPath;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Center(
        child: Icon(fallbackIcon, size: 16, color: const Color(0xFF717171)),
      ),
    );
  }
}
