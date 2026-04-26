import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/piano/courses/piano_basic_courses_page.dart';
import 'package:guidetar/presentation/pages/piano/tools/piano_sim_landscape_page.dart';
import 'package:guidetar/presentation/pages/piano/tools/piano_sheet_play_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class PianoToolkitPage extends StatefulWidget {
  const PianoToolkitPage({super.key});

  @override
  State<PianoToolkitPage> createState() => _PianoToolkitPageState();
}

class _PianoToolkitPageState extends State<PianoToolkitPage> {
  int _selectedNavIndex = 1;
  bool _gridMode = true;

  void _openPianoCourses() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PianoBasicCoursesPage()));
  }

  void _openSheetPlay() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PianoSheetPlayPage()));
  }

  Future<void> _openPianoSim() async {
    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    if (!mounted) return;

    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PianoSimLandscapePage()));

    await SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 83, 24, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _PianoHeader(),
                  const SizedBox(height: 22),
                  const _PianoHintRow(),
                  const SizedBox(height: 24),
                  _MainToolsSection(
                    gridMode: _gridMode,
                    onPianoSimTap: _openPianoSim,
                    onSheetPlayTap: _openSheetPlay,
                    onGridTap: () {
                      if (!_gridMode) {
                        setState(() {
                          _gridMode = true;
                        });
                      }
                    },
                    onListTap: () {
                      if (_gridMode) {
                        setState(() {
                          _gridMode = false;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 32),
                  _LessonsSection(onFirstLessonTap: _openPianoCourses),
                  const SizedBox(height: 32),
                  const _PianoSpotlightSection(),
                ],
              ),
            ),
          ),
          const _TopBar(),
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
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
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
            SizedBox(
              width: 14,
              height: 12,
              child: SvgPicture.asset('assets/icons/menu.svg'),
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
            Container(
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
          ],
        ),
      ),
    );
  }
}

class _PianoHeader extends StatelessWidget {
  const _PianoHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bộ công cụ Piano',
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
      ],
    );
  }
}

class _PianoHintRow extends StatelessWidget {
  const _PianoHintRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 18,
          height: 18,
          child: SvgPicture.asset('assets/icons/piano_toolkit_info.svg'),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            'Hãy tìm kiếm bản nhạc bạn yêu thích',
            style: GoogleFonts.playwriteUsTrad(
              color: const Color(0xFFADAAAA),
              fontSize: 16,
              height: 24 / 16,
            ),
          ),
        ),
      ],
    );
  }
}

class _MainToolsSection extends StatelessWidget {
  const _MainToolsSection({
    required this.gridMode,
    required this.onPianoSimTap,
    required this.onSheetPlayTap,
    required this.onGridTap,
    required this.onListTap,
  });

  final bool gridMode;
  final VoidCallback onPianoSimTap;
  final VoidCallback onSheetPlayTap;
  final VoidCallback onGridTap;
  final VoidCallback onListTap;

  @override
  Widget build(BuildContext context) {
    final tools = <_PianoToolItem>[
      _PianoToolItem(
        title: 'Piano Sim',
        description: 'giả lập đàn piano',
        iconAsset: 'assets/icons/piano_toolkit_icon_sim.svg',
        iconBg: Color.fromRGBO(255, 146, 62, 0.1),
        onTap: onPianoSimTap,
      ),
      _PianoToolItem(
        title: 'Sheet play',
        description: 'phát nhạc từ sheet',
        iconAsset: 'assets/icons/piano_toolkit_icon_sheet.svg',
        iconBg: Color.fromRGBO(255, 210, 98, 0.1),
        onTap: onSheetPlayTap,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Công cụ chính',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: const Color(0xFF131313),
                borderRadius: BorderRadius.circular(9999),
                border: Border.all(
                  color: const Color.fromRGBO(72, 72, 71, 0.1),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  _ModeButton(
                    text: 'Dạng lưới',
                    selected: gridMode,
                    onTap: onGridTap,
                  ),
                  _ModeButton(
                    text: 'Danh sách',
                    selected: !gridMode,
                    onTap: onListTap,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (!gridMode)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < tools.length; i++) ...[
                _ToolListItem(item: tools[i]),
                if (i != tools.length - 1) const SizedBox(height: 12),
              ],
            ],
          )
        else
          LayoutBuilder(
            builder: (context, constraints) {
              final width = (constraints.maxWidth - 16) / 2;
              return Row(
                children: [
                  SizedBox(
                    width: width,
                    child: _ToolCard(item: tools[0]),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: width,
                    child: _ToolCard(item: tools[1]),
                  ),
                ],
              );
            },
          ),
      ],
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
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFF923E) : Colors.transparent,
          borderRadius: BorderRadius.circular(9999),
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
          ),
        ),
      ),
    );
  }
}

class _PianoToolItem {
  const _PianoToolItem({
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.iconBg,
    this.onTap,
  });

  final String title;
  final String description;
  final String iconAsset;
  final Color iconBg;
  final VoidCallback? onTap;
}

class _ToolListItem extends StatelessWidget {
  const _ToolListItem({required this.item});

  final _PianoToolItem item;

  @override
  Widget build(BuildContext context) {
    final child = Container(
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
              color: item.iconBg,
              borderRadius: BorderRadius.circular(5),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 20,
              height: 16,
              child: SvgPicture.asset(item.iconAsset, fit: BoxFit.contain),
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
    );

    if (item.onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.item});

  final _PianoToolItem item;

  @override
  Widget build(BuildContext context) {
    final child = Container(
      constraints: const BoxConstraints(minHeight: 221),
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
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(16),
            ),
            alignment: Alignment.center,
            child: SizedBox(
              width: 28,
              height: 21,
              child: SvgPicture.asset(item.iconAsset, fit: BoxFit.contain),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            item.title,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
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
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );

    if (item.onTap == null) {
      return child;
    }

    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: child,
    );
  }
}

class _LessonsSection extends StatelessWidget {
  const _LessonsSection({required this.onFirstLessonTap});

  final VoidCallback onFirstLessonTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'CÁC BÀI HỌC',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFFF923E),
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.4,
                height: 20 / 14,
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
        GestureDetector(
          onTap: onFirstLessonTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: double.infinity,
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
                      'assets/images/piano_toolkit_lesson_1.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.center,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PIANO CƠ BẢN',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFFD262),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                          height: 15 / 10,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Khầy Quyền',
                        style: GoogleFonts.manrope(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Master Piano trong vài nốt nhạc , tin khầy',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFADAAAA),
                          fontSize: 12,
                          height: 16 / 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _PianoSpotlightSection extends StatelessWidget {
  const _PianoSpotlightSection();

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
              child: SvgPicture.asset(
                'assets/icons/guitar_toolkit_icon_decor_star.svg',
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giữ chuỗi ngay',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.2,
                  height: 24 / 24,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: 200,
                child: Text(
                  'Bạn có 2 bài học mới',
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
                  'Bắt đầu học',
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
