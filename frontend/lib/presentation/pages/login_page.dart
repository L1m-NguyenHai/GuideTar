import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/presentation/pages/home_page.dart';
import 'package:guidetar/presentation/pages/register_page.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/utils/app_constants.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const String _bgImageAsset = 'assets/images/login_bg.png';
  static const String _logoIconAsset = 'assets/icons/logo_note.svg';
  static const String _emailIconAsset = 'assets/icons/email.svg';
  static const String _lockIconAsset = 'assets/icons/lock.svg';
  static const String _eyeIconAsset = 'assets/icons/eye.svg';
  static const String _googleIconAsset = 'assets/icons/google.svg';
  static const String _discordIconAsset = 'assets/icons/discord.svg';
  static const String _facebookIconAsset = 'assets/icons/facebook.svg';

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        await BackendApi.login(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        if (!mounted) {
          return;
        }
        Navigator.of(
          context,
        ).pushReplacement(MaterialPageRoute(builder: (_) => const HomePage()));
      } on ApiException catch (error) {
        if (!mounted) {
          return;
        }
        _showErrorDialog(error.message);
      } catch (_) {
        if (!mounted) {
          return;
        }
        _showErrorDialog('Đăng nhập thất bại. Vui lòng thử lại.');
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: Text(
          'Đăng nhập thất bại',
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.manrope(color: const Color(0xFFADAAAA)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'OK',
              style: GoogleFonts.manrope(
                color: const Color(0xFFFF923E),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 24,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 448),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: 354,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeader(),
                          const Gap(48),
                          _buildLoginCard(),
                        ],
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            SizedBox(
              width: 18,
              height: 27,
              child: SvgPicture.asset(_logoIconAsset),
            ),
            const Gap(12),
            RichText(
              text: TextSpan(
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 36,
                  height: 40 / 36,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1.8,
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
        const Padding(padding: EdgeInsets.all(10), child: _TaglineText()),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(
            AppConstants.appTaglineVi,
            style: GoogleFonts.playwriteUsTrad(
              fontSize: 18,
              height: 29.25 / 18,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(33),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(26, 26, 26, 0.52),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color.fromRGBO(255, 255, 255, 0.05),
            ),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.25),
                offset: Offset(0, 25),
                blurRadius: 50,
                spreadRadius: -12,
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Xin chào!',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    height: 32 / 24,
                    letterSpacing: -0.6,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const Gap(24),
                _buildEmailField(),
                const Gap(24),
                _buildPasswordField(),
                const Gap(24),
                _buildLoginButton(),
                const Gap(16),
                _buildDividerLabel(),
                const Gap(9),
                _buildSocialButtons(),
                const Gap(16),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUpperLabel('EMAIL'),
        const Gap(8.5),
        _InputField(
          iconAsset: _emailIconAsset,
          hintText: 'example@gma...',
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildUpperLabel('MẬT KHẨU'),
            TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                'Quên mật khẩu?',
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  height: 16 / 12,
                  color: AppColors.primaryOrange,
                ),
              ),
            ),
          ],
        ),
        const Gap(8),
        _InputField(
          iconAsset: _lockIconAsset,
          hintText: '••••••••',
          controller: _passwordController,
          obscureText: true,
          trailing: SizedBox(
            width: 16.5,
            height: 11.25,
            child: SvgPicture.asset(_eyeIconAsset),
          ),
        ),
      ],
    );
  }

  Widget _buildUpperLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        height: 20 / 14,
        letterSpacing: 1.4,
        fontWeight: FontWeight.w600,
        color: AppColors.textSecondary,
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9999),
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
          onPressed: _isLoading ? null : _handleLogin,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            disabledBackgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(9999),
            ),
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(Color(0xFF3B1900)),
                  ),
                )
              : Text(
                  'Đăng nhập',
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

  Widget _buildDividerLabel() {
    return SizedBox(
      height: 40,
      child: Row(
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
              'HOẶC ĐĂNG NHẬP VỚI',
              style: GoogleFonts.manrope(
                fontSize: 12,
                height: 16 / 12,
                letterSpacing: 1.2,
                fontWeight: FontWeight.w700,
                color: AppColors.textSecondary,
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
      ),
    );
  }

  Widget _buildSocialButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(iconAsset: _googleIconAsset),
        const Gap(16),
        _SocialButton(iconAsset: _discordIconAsset),
        const Gap(16),
        _SocialButton(iconAsset: _facebookIconAsset),
      ],
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Wrap(
        spacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            'Không có tài khoản?',
            style: GoogleFonts.manrope(
              fontSize: 16,
              height: 24 / 16,
              color: AppColors.textSecondary,
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const RegisterPage()));
            },
            style: TextButton.styleFrom(
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.zero,
            ),
            child: Text(
              'Đăng ký ngay',
              style: GoogleFonts.manrope(
                fontSize: 16,
                height: 24 / 16,
                color: AppColors.primaryOrange,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TaglineText extends StatelessWidget {
  const _TaglineText();

  @override
  Widget build(BuildContext context) {
    return Text(
      AppConstants.appTagline,
      style: GoogleFonts.plusJakartaSans(
        color: AppColors.textSecondary,
        fontSize: 18,
        height: 29.25 / 18,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.iconAsset,
    required this.hintText,
    this.controller,
    this.keyboardType,
    this.obscureText = false,
    this.trailing,
  });

  final String iconAsset;
  final String hintText;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool obscureText;
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
          const Gap(16),
          SizedBox(width: 20, height: 21, child: SvgPicture.asset(iconAsset)),
          const Gap(12),
          Expanded(
            child: TextFormField(
              controller: controller,
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: GoogleFonts.manrope(color: Colors.white, fontSize: 16),
              validator: (value) {
                if (hintText.contains('gma') && (value?.isEmpty ?? true)) {
                  return 'Vui lòng nhập email';
                }
                if (obscureText && (value?.isEmpty ?? true)) {
                  return 'Vui lòng nhập mật khẩu';
                }
                return null;
              },
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: GoogleFonts.manrope(
                  color: const Color(0xFF767575),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (trailing != null) ...[trailing!, const Gap(16)],
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.iconAsset});

  final String iconAsset;

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
        child: SizedBox(
          width: 20,
          height: 20,
          child: SvgPicture.asset(iconAsset),
        ),
      ),
    );
  }
}
