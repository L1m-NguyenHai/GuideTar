import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({Key? key}) : super(key: key);

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int _selectedCategoryIndex = 0;

  final List<String> categories = [
    'Luyện tập',
    'Mục tiêu',
    'Nguồn cảm hứng',
    'Lý thuyết',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateStr =
        'Ngày ${now.day} tháng ${now.month}'; // Format: Ngày 26 tháng 10
    final timeStr =
        '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}'; // Format: 14:57

    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _AddNoteHeader(
              onSave: () {
                // TODO: Handle save action
              },
            ),
            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 96),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date and Time
                    _MetaSection(dateStr: dateStr, timeStr: timeStr),
                    const Gap(16),
                    // Category Chips
                    _CategoryChips(
                      categories: categories,
                      selectedIndex: _selectedCategoryIndex,
                      onCategorySelected: (index) {
                        setState(() {
                          _selectedCategoryIndex = index;
                        });
                      },
                    ),
                    const Gap(16),
                    // Title Input
                    _TitleInput(controller: _titleController),
                    const Gap(16),
                    // Content Input
                    _ContentInput(controller: _contentController),
                    const Gap(24),
                    // Link Section
                    const _LinkSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddNoteHeader extends StatelessWidget {
  final VoidCallback onSave;

  const _AddNoteHeader({required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF0E0E0D),
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Back button + Title
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const _SafeSvgAsset(
                  'assets/icons/profile_back.svg',
                  width: 16,
                  height: 16,
                ),
              ),
              const Gap(16),
              Text(
                'Thêm ghi chú',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFE5E2E0),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  height: 28 / 20,
                ),
              ),
            ],
          ),
          // Right: Save button
          GestureDetector(
            onTap: onSave,
            child: Text(
              'Lưu',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFF97F08),
                fontSize: 16,
                fontWeight: FontWeight.w700,
                height: 24 / 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaSection extends StatelessWidget {
  final String dateStr;
  final String timeStr;

  const _MetaSection({required this.dateStr, required this.timeStr});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Date
        Row(
          children: [
            const SizedBox(
              width: 10.5,
              height: 11.667,
              child: _SafeSvgAsset('assets/icons/calendar.svg'),
            ),
            const Gap(8.5),
            Text(
              dateStr,
              style: GoogleFonts.manrope(
                color: const Color(0xFFDEC1AF),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
        const Gap(16),
        // Time
        Row(
          children: [
            const SizedBox(
              width: 12,
              height: 12,
              child: _SafeSvgAsset('assets/icons/clock.svg'),
            ),
            const Gap(8),
            Text(
              timeStr,
              style: GoogleFonts.manrope(
                color: const Color(0xFFDEC1AF),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final Function(int) onCategorySelected;

  const _CategoryChips({
    required this.categories,
    required this.selectedIndex,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (index) => Padding(
            padding: EdgeInsets.only(right: index < categories.length - 1 ? 16 : 0),
            child: GestureDetector(
              onTap: () => onCategorySelected(index),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: index == selectedIndex
                      ? const Color(0xFFF97F08)
                      : const Color(0xFF2A2A29),
                  borderRadius: BorderRadius.circular(9999),
                  boxShadow: index == selectedIndex
                      ? [
                          BoxShadow(
                            color: const Color(0xFFF97F08).withValues(alpha: 0.2),
                            blurRadius: 15,
                            offset: const Offset(0, 0),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  categories[index],
                  style: GoogleFonts.manrope(
                    color: index == selectedIndex
                        ? const Color(0xFF5B2A00)
                        : const Color(0xFFDEC1AF),
                    fontSize: 12,
                    fontWeight: index == selectedIndex
                        ? FontWeight.w700
                        : FontWeight.w600,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TitleInput extends StatelessWidget {
  final TextEditingController controller;

  const _TitleInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.spaceGrotesk(
        color: const Color(0xFFE5E2E0),
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2.4,
      ),
      decoration: InputDecoration(
        hintText: 'Tiêu đề',
        hintStyle: GoogleFonts.spaceGrotesk(
          color: const Color(0xFF353533),
          fontSize: 48,
          fontWeight: FontWeight.w700,
          letterSpacing: -2.4,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
    );
  }
}

class _ContentInput extends StatelessWidget {
  final TextEditingController controller;

  const _ContentInput({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: GoogleFonts.manrope(
        color: const Color(0xFFE5E2E0),
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 29.25 / 18,
      ),
      decoration: InputDecoration(
        hintText: 'Ghi lại suy nghĩ nghệ thuật của bạn',
        hintStyle: GoogleFonts.manrope(
          color: const Color(0xFF353533),
          fontSize: 18,
          fontWeight: FontWeight.w400,
          height: 29.25 / 18,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        contentPadding: EdgeInsets.zero,
      ),
      maxLines: null,
      minLines: 6,
    );
  }
}

class _LinkSection extends StatelessWidget {
  const _LinkSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Row(
          children: [
            const SizedBox(
              width: 20,
              height: 10,
              child: _SafeSvgAsset('assets/icons/link_icon.svg'),
            ),
            const Gap(12),
            Text(
              'Liên kết',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFE5E2E0),
                fontSize: 20,
                fontWeight: FontWeight.w700,
                height: 28 / 20,
              ),
            ),
          ],
        ),
        const Gap(24),
        // Add Link Button
        GestureDetector(
          onTap: () {
            // TODO: Handle link/attachment
          },
          child: Container(
            width: double.infinity,
            height: 122,
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1A),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color.fromRGBO(87, 66, 53, 0.3),
                width: 1,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Search Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A29),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                  child: const Center(
                    child: SizedBox(
                      width: 18,
                      height: 18,
                      child: _SafeSvgAsset('assets/icons/search_icon.svg'),
                    ),
                  ),
                ),
                const Gap(12),
                // Text
                Text(
                  'Gắn bài học hoặc bài hát',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFDEC1AF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.35,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SafeSvgAsset extends StatelessWidget {
  final String assetPath;
  final double? width;
  final double? height;

  const _SafeSvgAsset(
    this.assetPath, {
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (width != null && height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: SvgPicture.asset(
          assetPath,
          fit: BoxFit.contain,
          placeholderBuilder: (BuildContext context) {
            return const Icon(
              Icons.image_not_supported,
              color: Colors.grey,
            );
          },
        ),
      );
    }
    return SvgPicture.asset(
      assetPath,
      placeholderBuilder: (BuildContext context) {
        return const Icon(
          Icons.image_not_supported,
          color: Colors.grey,
        );
      },
    );
  }
}
