import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';
import 'package:guidetar/presentation/pages/piano/tools/piano_sheet_loading_page.dart';
import 'package:guidetar/presentation/pages/profile_page.dart';
import 'package:guidetar/presentation/pages/recent_page.dart';

class PianoSheetPlayPage extends StatefulWidget {
  const PianoSheetPlayPage({super.key});

  @override
  State<PianoSheetPlayPage> createState() => _PianoSheetPlayPageState();
}

class _PianoSheetPlayPageState extends State<PianoSheetPlayPage> {
  int _selectedNavIndex = 1;

  void _openLoading() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const PianoSheetLoadingPage()));
  }

  void _onNavbarChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    if (index == 2) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
      return;
    }
    if (index == 3) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const RecentPage()));
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0E14),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 96, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _EditorialHeader(),
                  const SizedBox(height: 40),
                  _PrimaryUploadSection(onUploadTap: _openLoading),
                  const SizedBox(height: 32),
                  const _RecentUploadsSection(),
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
                onChanged: _onNavbarChanged,
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
    return Container(
      height: 64,
      color: const Color(0xFF10131A),
      padding: const EdgeInsets.fromLTRB(14, 18, 24, 18),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: const _SafeSvgAsset('assets/icons/piano_sheet_back.svg'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Chơi sheet nhạc',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFECEDF6),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.5,
                height: 28 / 20,
              ),
            ),
          ),
          SizedBox(
            width: 20.1,
            height: 20,
            child: const _SafeSvgAsset('assets/icons/piano_sheet_more.svg'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tải lên nhạc của bạn',
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFECEDF6),
            fontSize: 42,
            fontWeight: FontWeight.w800,
            letterSpacing: -2,
            height: 48 / 42,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Biến các bản nhạc của bạn thành những kiệt tác tương tác. Hỗ trợ PDF, MusicXML và MIDI.',
          style: GoogleFonts.inter(
            color: const Color(0xFFA9ABB3),
            fontSize: 18,
            fontWeight: FontWeight.w500,
            height: 28 / 18,
          ),
        ),
      ],
    );
  }
}

class _PrimaryUploadSection extends StatelessWidget {
  const _PrimaryUploadSection({required this.onUploadTap});

  final VoidCallback onUploadTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: const Color(0xFF161A21),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: const Color.fromRGBO(69, 72, 79, 0.3),
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF22262F),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 33,
                  height: 24,
                  child: _SafeSvgAsset('assets/icons/piano_sheet_upload.svg'),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Chọn File',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFECEDF6),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  height: 32 / 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nhấn vào nút bên dưới để chọn file',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  color: const Color(0xFFA9ABB3),
                  fontSize: 16,
                  height: 24 / 16,
                ),
              ),
              const SizedBox(height: 32),
              GestureDetector(
                onTap: onUploadTap,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 16,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9F4A),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: Text(
                    'Tải file',
                    style: GoogleFonts.inter(
                      color: const Color(0xFF532A00),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      height: 24 / 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF10131A),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF161A21),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: const SizedBox(
                  width: 14,
                  height: 19,
                  child: _SafeSvgAsset('assets/icons/piano_sheet_record.svg'),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ghi âm',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFECEDF6),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 24 / 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Chuyển đổi bản nhạc thu trực tiếp sang bản nhạc kỹ thuật số',
                      style: GoogleFonts.inter(
                        color: const Color(0xFFA9ABB3),
                        fontSize: 14,
                        height: 20 / 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const SizedBox(
                width: 7.4,
                height: 12,
                child: _SafeSvgAsset('assets/icons/piano_sheet_chevron.svg'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecentUploadsSection extends StatelessWidget {
  const _RecentUploadsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tải lên gần đây',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFECEDF6),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
              ),
            ),
            Text(
              'XEM TẤT CẢ',
              style: GoogleFonts.inter(
                color: const Color(0xFFFF9F4A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.4,
                height: 20 / 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _RecentUploadItem(
          thumbnailAsset: 'assets/images/piano_sheet_thumb_1.png',
          title: 'Nocturne in Eb Major',
          meta: 'CHOPIN • 2 phút trước',
          action: 'CHOPIN • 2 phút trước',
        ),
        const SizedBox(height: 16),
        const _RecentUploadItem(
          thumbnailAsset: 'assets/images/piano_sheet_thumb_2.png',
          title: 'Moonlight Sonata',
          meta: 'BEETHOVEN • 1 giờ trước',
          action: 'Phân tích',
        ),
        const SizedBox(height: 16),
        const _RecentUploadItem(
          thumbnailAsset: 'assets/images/piano_sheet_thumb_3.png',
          title: 'Clair de Lune',
          meta: 'DEBUSSY • 3 giờ trước',
          action: 'Phân tích',
        ),
      ],
    );
  }
}

class _RecentUploadItem extends StatelessWidget {
  const _RecentUploadItem({
    required this.thumbnailAsset,
    required this.title,
    required this.meta,
    required this.action,
  });

  final String thumbnailAsset;
  final String title;
  final String meta;
  final String action;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF161A21),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 64,
              height: 80,
              child: Opacity(
                opacity: 0.6,
                child: Image.asset(thumbnailAsset, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: SizedBox(
              height: 80,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFECEDF6),
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 20 / 14,
                        ),
                      ),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          color: const Color(0xFFA9ABB3),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                          height: 15 / 10,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF22262F),
                      borderRadius: BorderRadius.circular(9999),
                    ),
                    child: Text(
                      action,
                      style: GoogleFonts.inter(
                        color: const Color(0xFFFF9F4A),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        height: 15 / 10,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SafeSvgAsset extends StatelessWidget {
  const _SafeSvgAsset(this.assetPath);

  final String assetPath;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      assetPath,
      fit: BoxFit.contain,
      placeholderBuilder: (context) => Center(
        child: Icon(Icons.image_not_supported, size: 16, color: const Color(0xFF717171)),
      ),
    );
  }
}
