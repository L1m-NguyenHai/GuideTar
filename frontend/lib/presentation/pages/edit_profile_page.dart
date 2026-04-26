import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late TextEditingController _fullNameController;
  late TextEditingController _dateOfBirthController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  bool _isSaving = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _dateOfBirthController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _bioController = TextEditingController();
    _loadProfile();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _dateOfBirthController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await BackendApi.getMe();
      if (!mounted) {
        return;
      }
      _fullNameController.text =
          (profile['display_name'] ?? profile['username'] ?? '').toString();
      _emailController.text = (profile['email'] ?? '').toString();
      _bioController.text = (profile['bio'] ?? '').toString();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleSaveChanges() async {
    if (_isSaving) {
      return;
    }
    setState(() {
      _isSaving = true;
    });
    try {
      await BackendApi.updateMe(
        displayName: _fullNameController.text.trim(),
        bio: _bioController.text.trim(),
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Đã lưu thay đổi')));
      Navigator.of(context).maybePop();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _handleDiscard() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0D),
      body: SafeArea(
        child: Stack(
          children: [
            // Main scrollable content
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 72, 24, 140),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar Section
                  _AvatarSection(
                    onChangeAvatarTap: () {
                      // TODO: Implement image picker
                    },
                  ),
                  const Gap(48),
                  // Form Fields
                  _EditProfileForm(
                    fullNameController: _fullNameController,
                    dateOfBirthController: _dateOfBirthController,
                    emailController: _emailController,
                    phoneController: _phoneController,
                    bioController: _bioController,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
            // Top Header
            const _EditProfileHeader(),
            // Bottom Action Bar
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _BottomActionBar(
                onDiscardPressed: _handleDiscard,
                onSavePressed: _isLoading
                    ? null
                    : () {
                        _handleSaveChanges();
                      },
                isSaving: _isSaving,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EditProfileHeader extends StatelessWidget {
  const _EditProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: const Color(0xFF0E0E0D),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).maybePop(),
                behavior: HitTestBehavior.opaque,
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: _SafeSvgAsset('assets/icons/profile_back.svg'),
                ),
              ),
              const Gap(16),
              Text(
                'Chỉnh sửa thông tin',
                style: GoogleFonts.spaceGrotesk(
                  color: const Color(0xFFE5E2E0),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                  height: 28 / 20,
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                width: 12,
                height: 18,
                child: _SafeSvgAsset('assets/icons/profile_logo_note.svg'),
              ),
              const Gap(8),
              Text(
                'GuideTar',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF4F4F5),
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1,
                  height: 28 / 20,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvatarSection extends StatelessWidget {
  final VoidCallback onChangeAvatarTap;

  const _AvatarSection({required this.onChangeAvatarTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFF2A2A29), width: 4),
              borderRadius: BorderRadius.circular(9999),
              image: const DecorationImage(
                image: NetworkImage('assets/images/guitar_course_avatar.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const Gap(16),
          GestureDetector(
            onTap: onChangeAvatarTap,
            child: Text(
              'Đổi ảnh đại diện',
              style: GoogleFonts.spaceGrotesk(
                color: const Color(0xFFFFB786),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EditProfileForm extends StatelessWidget {
  final TextEditingController fullNameController;
  final TextEditingController dateOfBirthController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController bioController;
  final bool isLoading;

  const _EditProfileForm({
    required this.fullNameController,
    required this.dateOfBirthController,
    required this.emailController,
    required this.phoneController,
    required this.bioController,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 40),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    return Column(
      children: [
        _EditProfileFormField(
          label: 'Họ và tên',
          controller: fullNameController,
        ),
        const Gap(32),
        _EditProfileFormField(
          label: 'Ngày sinh',
          controller: dateOfBirthController,
          suffix: _SafeSvgAsset('assets/icons/calendar.svg'),
        ),
        const Gap(32),
        _EditProfileFormField(
          label: 'Địa chỉ email',
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const Gap(32),
        _EditProfileFormField(
          label: 'Số điện thoại',
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        const Gap(32),
        _EditProfileFormField(
          label: 'Mô tả bản thân',
          controller: bioController,
          maxLines: 4,
          minLines: 4,
        ),
      ],
    );
  }
}

class _EditProfileFormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final int maxLines;
  final int minLines;
  final Widget? suffix;

  const _EditProfileFormField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
    this.minLines = 1,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            color: const Color(0xFFDEC1AF),
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const Gap(8),
        // Input Field
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF20201E),
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: suffix != null
              ? Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        keyboardType: keyboardType,
                        maxLines: maxLines,
                        minLines: minLines,
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFE5E2E0),
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    const Gap(12),
                    SizedBox(width: 20, height: 20, child: suffix),
                  ],
                )
              : TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  maxLines: maxLines,
                  minLines: minLines,
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFE5E2E0),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
        ),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  final VoidCallback onDiscardPressed;
  final VoidCallback? onSavePressed;
  final bool isSaving;

  const _BottomActionBar({
    required this.onDiscardPressed,
    required this.onSavePressed,
    required this.isSaving,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF20201E).withValues(alpha: 0.8),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF97F08).withValues(alpha: 0.1),
            blurRadius: 40,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Discard Button
          GestureDetector(
            onTap: onDiscardPressed,
            behavior: HitTestBehavior.opaque,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: _SafeSvgAsset('assets/icons/close.svg'),
                ),
                const Gap(4),
                Text(
                  'Huỷ',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFFDEC1AF),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
          ),
          // Save Button
          GestureDetector(
            onTap: onSavePressed,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF97F08),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFF97F08).withValues(alpha: 0.3),
                    blurRadius: 15,
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: _SafeSvgAsset('assets/icons/check.svg'),
                  ),
                  const Gap(8),
                  Text(
                    isSaving ? 'Đang lưu...' : 'Lưu Thay đổi',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFFFFFFF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1.2,
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
        child: Icon(
          Icons.image_not_supported,
          size: 16,
          color: const Color(0xFF717171),
        ),
      ),
    );
  }
}
