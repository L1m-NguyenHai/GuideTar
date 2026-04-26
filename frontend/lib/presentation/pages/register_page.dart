import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/home_page.dart';

enum _RegisterStep { email, emailReview, password, username }

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const String _bgImageAsset = 'assets/images/login_bg.png';
  static const String _logoIconAsset = 'assets/icons/logo_note.svg';
  static const String _emailIconAsset = 'assets/icons/email.svg';
  static const String _lockIconAsset = 'assets/icons/lock.svg';
  static const String _eyeIconAsset = 'assets/icons/eye.svg';
  static const String _googleIconAsset = 'assets/icons/google.svg';
  static const String _discordIconAsset = 'assets/icons/discord.svg';
  static const String _facebookIconAsset = 'assets/icons/facebook.svg';

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  _RegisterStep _currentStep = _RegisterStep.email;
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  bool get _showSocialSection {
    return _currentStep == _RegisterStep.email ||
        _currentStep == _RegisterStep.emailReview;
  }

  bool get _showBackAction {
    return _currentStep == _RegisterStep.password ||
        _currentStep == _RegisterStep.username;
  }

  void _goBackStep() {
    setState(() {
      switch (_currentStep) {
        case _RegisterStep.email:
          Navigator.of(context).maybePop();
          break;
        case _RegisterStep.emailReview:
          _currentStep = _RegisterStep.email;
          break;
        case _RegisterStep.password:
          _currentStep = _RegisterStep.emailReview;
          break;
        case _RegisterStep.username:
          _currentStep = _RegisterStep.password;
          break;
      }
    });
  }

  Future<void> _onContinue() async {
    if (_isSubmitting) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final username = _usernameController.text.trim();

    if (_currentStep == _RegisterStep.email && email.isEmpty) {
      _showSnackBar('Vui lòng nhập email.');
      return;
    }

    if (_currentStep == _RegisterStep.password &&
        _passwordController.text.trim().isEmpty) {
      _showSnackBar('Vui lòng nhập mật khẩu.');
      return;
    }

    if (_currentStep == _RegisterStep.username && username.isEmpty) {
      _showSnackBar('Vui lòng nhập nghệ danh.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    switch (_currentStep) {
      case _RegisterStep.email:
        setState(() {
          _currentStep = _RegisterStep.emailReview;
          _isSubmitting = false;
        });
        break;
      case _RegisterStep.emailReview:
        setState(() {
          _currentStep = _RegisterStep.password;
          _isSubmitting = false;
        });
        break;
      case _RegisterStep.password:
        setState(() {
          _currentStep = _RegisterStep.username;
          _isSubmitting = false;
        });
        break;
      case _RegisterStep.username:
        try {
          await BackendApi.register(
            email: email,
            password: _passwordController.text.trim(),
            username: username,
          );
          if (!mounted) {
            return;
          }
          _showSnackBar('Đăng ký thành công!');
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const HomePage()),
            (route) => false,
          );
        } on ApiException catch (error) {
          if (!mounted) {
            return;
          }
          setState(() {
            _isSubmitting = false;
          });
          _showConflictModal(
            title: 'Đăng ký chưa thành công',
            message: error.message,
            primaryActionText: null,
            secondaryActionText: 'Đã hiểu',
            onSecondaryPressed: () => Navigator.of(context).pop(),
          );
          return;
        }
        break;
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF1F1F1F),
          content: Text(
            message,
            style: GoogleFonts.manrope(color: Colors.white),
          ),
        ),
      );
  }

  void _showConflictModal({
    required String title,
    required String message,
    required String? primaryActionText,
    required String secondaryActionText,
    required VoidCallback onSecondaryPressed,
    VoidCallback? onPrimaryPressed,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.52),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 392),
            decoration: BoxDecoration(
              color: const Color(0xFF20201F),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color.fromRGBO(72, 72, 71, 0.15)),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.5),
                  offset: Offset(0, 20),
                  blurRadius: 50,
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Color(0xFF888888),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                  const Gap(8),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color.fromRGBO(185, 41, 2, 0.2),
                      border: Border.all(
                        color: const Color.fromRGBO(255, 115, 81, 0.2),
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromRGBO(255, 146, 62, 0.15),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_off,
                      color: AppColors.primaryOrange,
                      size: 30,
                    ),
                  ),
                  const Gap(24),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 24,
                      height: 32 / 24,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const Gap(12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 16,
                        height: 26 / 16,
                        color: const Color(0xFFADAAAA),
                      ),
                    ),
                  ),
                  const Gap(32),
                  if (primaryActionText != null) ...[
                    _GradientActionButton(
                      label: primaryActionText,
                      onPressed: onPrimaryPressed!,
                    ),
                    const Gap(12),
                  ],
                  _OutlineActionButton(
                    label: secondaryActionText,
                    onPressed: onSecondaryPressed,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isPasswordStep = _currentStep == _RegisterStep.password;
    final bool isUsernameStep = _currentStep == _RegisterStep.username;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(child: Image.asset(_bgImageAsset, fit: BoxFit.cover)),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment(-1.0, -0.2),
                  end: Alignment(1.0, 0.8),
                  colors: [
                    Color.fromRGBO(14, 14, 14, 0.34),
                    Color.fromRGBO(14, 14, 14, 0.30),
                    Color.fromRGBO(14, 14, 14, 0.18),
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.45)),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(33),
                        decoration: BoxDecoration(
                          color: const Color.fromRGBO(26, 26, 26, 0.7),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color.fromRGBO(255, 255, 255, 0.1),
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color.fromRGBO(0, 0, 0, 0.6),
                              offset: Offset(0, 32),
                              blurRadius: 64,
                              spreadRadius: -16,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (_showBackAction)
                                  IconButton(
                                    visualDensity: VisualDensity.compact,
                                    onPressed: _goBackStep,
                                    icon: const Icon(
                                      Icons.undo,
                                      color: Color(0xFFADAAAA),
                                    ),
                                  ),
                                const Spacer(),
                                IconButton(
                                  visualDensity: VisualDensity.compact,
                                  onPressed: () =>
                                      Navigator.of(context).maybePop(),
                                  icon: const Icon(
                                    Icons.close,
                                    color: Color(0xFFADAAAA),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(4),
                            _buildBranding(),
                            const Gap(24),
                            if (_showSocialSection) ...[
                              _buildSocialButtons(),
                              const Gap(20),
                              _buildDividerLabel(),
                              const Gap(20),
                            ] else
                              _buildInlineContextLabel(),
                            if (_showSocialSection)
                              _buildEmailInput(
                                showStaticValue:
                                    _currentStep == _RegisterStep.emailReview,
                              ),
                            if (isPasswordStep) _buildPasswordInput(),
                            if (isUsernameStep) _buildUsernameInput(),
                            const Gap(20),
                            _GradientActionButton(
                              label: 'Tiếp Theo',
                              isLoading: _isSubmitting,
                              onPressed: _onContinue,
                            ),
                            const Gap(28),
                            _buildLoginLink(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBranding() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 18,
              height: 27,
              child: SvgPicture.asset(_logoIconAsset),
            ),
            const Gap(8),
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 42 * (30 / 42),
                  height: 36 / 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.5,
                  color: Colors.white,
                ),
                children: const [
                  TextSpan(text: 'Guide'),
                  TextSpan(
                    text: 'Tar',
                    style: TextStyle(color: AppColors.primaryOrange),
                  ),
                ],
              ),
            ),
          ],
        ),
        const Gap(4),
        Text(
          'Chào mừng',
          textAlign: TextAlign.center,
          style: GoogleFonts.plusJakartaSans(
            fontSize: 24,
            height: 32 / 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: -0.6,
          ),
        ),
        const Gap(4),
        Text(
          'Bắt đầu hành trình nghệ sĩ của bạn ngay',
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            height: 20 / 14,
            color: const Color(0xFFADAAAA),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _SocialIconButton(asset: _googleIconAsset),
        Gap(16),
        _SocialIconButton(asset: _discordIconAsset),
        Gap(16),
        _SocialIconButton(asset: _facebookIconAsset),
      ],
    );
  }

  Widget _buildDividerLabel() {
    return Row(
      children: [
        const Expanded(
          child: Divider(
            color: Color.fromRGBO(255, 255, 255, 0.05),
            thickness: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'HOẶC ĐĂNG KÝ VỚI',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 16 / 12,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFADAAAA),
            ),
          ),
        ),
        const Expanded(
          child: Divider(
            color: Color.fromRGBO(255, 255, 255, 0.05),
            thickness: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildInlineContextLabel() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const SizedBox(width: 17),
          Text(
            'EMAIL: ',
            style: GoogleFonts.manrope(
              fontSize: 12,
              height: 16 / 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: const Color(0xFF878484),
            ),
          ),
          Expanded(
            child: Text(
              _emailController.text.trim().isEmpty
                  ? 'nghesi@gmail.com'
                  : _emailController.text.trim(),
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.manrope(
                fontSize: 12,
                height: 16 / 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: Colors.white,
              ),
            ),
          ),
          const Gap(16),
          const Expanded(
            child: Divider(
              color: Color.fromRGBO(255, 255, 255, 0.05),
              thickness: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailInput({required bool showStaticValue}) {
    return _RegisterFieldContainer(
      label: 'ĐỊA CHỈ EMAIL',
      child: _IconInputRow(
        iconAsset: _emailIconAsset,
        child: TextField(
          controller: _emailController,
          readOnly: showStaticValue,
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'nghesi@guidetar.vn',
            hintStyle: GoogleFonts.manrope(
              color: const Color(0xFF767575).withValues(alpha: 0.5),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordInput() {
    return _RegisterFieldContainer(
      label: 'MẬT KHẨU',
      child: _IconInputRow(
        iconAsset: _lockIconAsset,
        trailing: IconButton(
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
          icon: SizedBox(
            width: 16.5,
            height: 11.25,
            child: SvgPicture.asset(_eyeIconAsset),
          ),
        ),
        child: TextField(
          controller: _passwordController,
          obscureText: _obscurePassword,
          style: GoogleFonts.manrope(fontSize: 16, color: Colors.white),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: '••••••••',
            hintStyle: GoogleFonts.manrope(
              color: const Color(0xFF767575),
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameInput() {
    return _RegisterFieldContainer(
      label: 'USERNAME',
      centeredLabel: true,
      child: _IconInputRow(
        child: TextField(
          controller: _usernameController,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 12,
            height: 16.5 / 11,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFEDE6E6),
          ),
          decoration: InputDecoration(
            border: InputBorder.none,
            hintText: 'NHẬP NGHỆ DANH CỦA BẠN',
            hintStyle: GoogleFonts.manrope(
              fontSize: 11,
              height: 16.5 / 11,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFEDE6E6),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 4,
        children: [
          Text(
            'Đã có tài khoản?',
            style: GoogleFonts.manrope(
              fontSize: 14,
              height: 20 / 14,
              color: const Color(0xFFADAAAA),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).maybePop(),
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Đăng nhập ngay',
              style: GoogleFonts.manrope(
                fontSize: 14,
                height: 20 / 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RegisterFieldContainer extends StatelessWidget {
  const _RegisterFieldContainer({
    required this.label,
    required this.child,
    this.centeredLabel = false,
  });

  final String label;
  final Widget child;
  final bool centeredLabel;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: centeredLabel
          ? CrossAxisAlignment.stretch
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          textAlign: centeredLabel ? TextAlign.center : TextAlign.start,
          style: GoogleFonts.manrope(
            fontSize: 11,
            height: 16.5 / 11,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w700,
            color: const Color(0xFFADAAAA),
          ),
        ),
        const Gap(8.5),
        child,
      ],
    );
  }
}

class _IconInputRow extends StatelessWidget {
  const _IconInputRow({required this.child, this.iconAsset, this.trailing});

  final String? iconAsset;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 38, 38, 0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          if (iconAsset != null) ...[
            const Gap(16),
            SizedBox(
              width: 16.7,
              height: 21,
              child: SvgPicture.asset(iconAsset!),
            ),
            const Gap(12),
          ] else
            const Gap(16),
          Expanded(child: child),
          if (trailing != null) ...[trailing!, const Gap(8)] else const Gap(16),
        ],
      ),
    );
  }
}

class _SocialIconButton extends StatelessWidget {
  const _SocialIconButton({required this.asset});

  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color.fromRGBO(38, 38, 38, 0.5),
        shape: BoxShape.circle,
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Center(
        child: SizedBox(width: 20, height: 20, child: SvgPicture.asset(asset)),
      ),
    );
  }
}

class _GradientActionButton extends StatelessWidget {
  const _GradientActionButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFFFF923E), Color(0xFFF97F06)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(255, 146, 62, 0.2),
              offset: Offset(0, 10),
              blurRadius: 15,
              spreadRadius: -3,
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3B1900)),
                  ),
                )
              : Text(
                  label,
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 36 * 0.5,
                    height: 28 / 18,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF3B1900),
                  ),
                ),
        ),
      ),
    );
  }
}

class _OutlineActionButton extends StatelessWidget {
  const _OutlineActionButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color.fromRGBO(72, 72, 71, 0.2)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.manrope(
            fontSize: 14,
            height: 20 / 14,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
