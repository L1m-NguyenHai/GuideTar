import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/membership_payment_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

enum _PlanType { solo, maestro }

class MembershipRegisterPage extends StatefulWidget {
  const MembershipRegisterPage({super.key});

  @override
  State<MembershipRegisterPage> createState() => _MembershipRegisterPageState();
}

class _MembershipRegisterPageState extends State<MembershipRegisterPage> {
  final PageController _pageController = PageController(
    viewportFraction: 0.9,
    initialPage: 1,
  );

  int _selectedNavIndex = 2;
  bool _isYearly = false;
  _PlanType _focusedPlan = _PlanType.maestro;
  _PlanType _currentPlan = _PlanType.maestro;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectBilling(bool yearly) {
    if (_isYearly == yearly) {
      return;
    }
    setState(() {
      _isYearly = yearly;
    });
  }

  Future<void> _showMaestroPopupAndContinue() async {
    final approved = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierColor: const Color.fromRGBO(0, 0, 0, 0.65),
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF25272C), Color(0xFF1A1B1F)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'MAESTRO',
                      style: GoogleFonts.plusJakartaSans(
                        color: Colors.white,
                        fontSize: 60 * 0.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Khai phá toàn bộ tiềm năng của nhạc\ncụ của bạn với bộ tính năng cao cấp\ncủa chúng tôi.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFFBBB6B1),
                        fontSize: 16 * 0.8,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _PopupFeature(
                      icon: Icons.equalizer,
                      title: 'Phân tích kỹ năng chơi nhạc',
                      subtitle: 'Chấm điểm và phát hiện lỗi khi chơi nhạc.',
                    ),
                    const SizedBox(height: 8),
                    _PopupFeature(
                      icon: Icons.cloud_outlined,
                      title: 'Thư viện bài hát cao cấp',
                      subtitle: 'Truy cập kho bài hát độc quyền, đa dạng.',
                    ),
                    const SizedBox(height: 8),
                    _PopupFeature(
                      icon: Icons.self_improvement,
                      title: 'Chế độ luyện tập thông minh',
                      subtitle:
                          'Luyện tập hiệu quả với lặp đoạn và điều chỉnh tốc độ.',
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: 220,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF79633),
                          foregroundColor: const Color(0xFF2A2D30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'DÙNG THỬ 2 TUẦN',
                          maxLines: 1,
                          overflow: TextOverflow.visible,
                          softWrap: false,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Sau đó 63.000 VNĐ/tháng. Huỷ bất cứ lúc nào.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF8E8C88),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: GestureDetector(
                  onTap: () => Navigator.of(dialogContext).pop(false),
                  child: const Icon(Icons.close, color: Color(0xFFE6DDD6), size: 22),
                ),
              ),
            ],
          ),
        );
      },
    );

    if (!mounted || approved != true) {
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const MembershipPaymentPage()),
    );
  }

  void _onSubscribe(_PlanType plan) {
    if (_currentPlan == plan) {
      return;
    }

    if (plan == _PlanType.maestro) {
      _showMaestroPopupAndContinue();
      return;
    }

    setState(() {
      _currentPlan = plan;
    });

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            plan == _PlanType.maestro
                ? 'Bạn đã đăng ký gói MAESTRO.'
                : 'Bạn đã chuyển về gói SOLO.',
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111011),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                const SizedBox(height: 80),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'CHỌN GÓI ĐĂNG KÝ',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                _BillingToggle(
                  isYearly: _isYearly,
                  onMonthlyTap: () => _selectBilling(false),
                  onYearlyTap: () => _selectBilling(true),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 104),
                    child: PageView(
                      clipBehavior: Clip.none,
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() {
                          _focusedPlan = index == 0
                              ? _PlanType.solo
                              : _PlanType.maestro;
                        });
                      },
                      children: [
                        _PlanCard(
                          isMaestro: false,
                          isYearly: _isYearly,
                          isFocused: _focusedPlan == _PlanType.solo,
                          isCurrent: _currentPlan == _PlanType.solo,
                          onActionTap: () => _onSubscribe(_PlanType.solo),
                        ),
                        _PlanCard(
                          isMaestro: true,
                          isYearly: _isYearly,
                          isFocused: _focusedPlan == _PlanType.maestro,
                          isCurrent: _currentPlan == _PlanType.maestro,
                          onActionTap: () => _onSubscribe(_PlanType.maestro),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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

class _PopupFeature extends StatelessWidget {
  const _PopupFeature({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF2B2D31),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, color: const Color(0xFF7CCBFF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 20 * 0.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF7CCBFF),
                    fontSize: 12,
                    height: 1.4,
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
  const _TopBar({required this.onBackTap});

  final VoidCallback onBackTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.70)),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBackTap,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFFFFB77D),
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'ĐĂNG KÍ HỘI VIÊN',
              textAlign: TextAlign.left,
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFFFB77D),
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ),
          Row(
            children: [
              const Icon(Icons.music_note, color: Color(0xFFF97F06), size: 18),
              const SizedBox(width: 4),
              Text(
                'GuideTar',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BillingToggle extends StatelessWidget {
  const _BillingToggle({
    required this.isYearly,
    required this.onMonthlyTap,
    required this.onYearlyTap,
  });

  final bool isYearly;
  final VoidCallback onMonthlyTap;
  final VoidCallback onYearlyTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF191A1F),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ToggleButton(
              label: 'THÁNG',
              active: !isYearly,
              trailing: null,
              onTap: onMonthlyTap,
            ),
          ),
          Expanded(
            child: _ToggleButton(
              label: 'NĂM',
              active: isYearly,
              trailing: '-20%',
              onTap: onYearlyTap,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  const _ToggleButton({
    required this.label,
    required this.active,
    required this.trailing,
    required this.onTap,
  });

  final String label;
  final bool active;
  final String? trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: active ? const Color(0xFF37393E) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: active ? const Color(0xFFF97F06) : const Color(0xFF726F73),
                fontSize: 16 * 0.8,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Text(
                trailing!,
                style: GoogleFonts.plusJakartaSans(
                  color: active
                      ? const Color(0xFFF2A26D)
                      : const Color(0xFFA48672),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.isMaestro,
    required this.isYearly,
    required this.isFocused,
    required this.isCurrent,
    required this.onActionTap,
  });

  final bool isMaestro;
  final bool isYearly;
  final bool isFocused;
  final bool isCurrent;
  final VoidCallback onActionTap;

  @override
  Widget build(BuildContext context) {
    final hasDiscount = isMaestro && isYearly;
    final cardOpacity = isFocused ? 1.0 : 0.88;

    return Opacity(
      opacity: cardOpacity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Align(
          alignment: Alignment.topCenter,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isMaestro
                        ? const Color(0xFFFFB77D)
                        : const Color(0xFF45474D),
                    width: 2,
                  ),
                  gradient: const LinearGradient(
                    begin: Alignment(-0.9, -1),
                    end: Alignment(1, 1),
                    colors: [Color(0xFF2F3238), Color(0xFF25262B)],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Row(
                    children: [
                      Text(
                        isMaestro ? 'TRẢ PHÍ' : 'MIỄN PHÍ',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFFB77D),
                          fontSize: 22 * 0.8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      if (hasDiscount)
                        Text(
                          '- 20%',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFFFB77D),
                            fontSize: 24 * 0.8,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMaestro ? 'MAESTRO' : 'SOLO',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 50 * 0.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isMaestro
                        ? (isYearly ? '50.000 VNĐ' : '63.000 VNĐ')
                        : '0 VNĐ',
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 58 * 0.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.9,
                    ),
                  ),
                  if (hasDiscount)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        '63.000 VNĐ',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFB5875F),
                          fontSize: 57 * 0.5,
                          fontWeight: FontWeight.w700,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: const Color(0xFFB5875F),
                        ),
                      ),
                    ),
                  const SizedBox(height: 26),
                  if (isMaestro) ...[
                    _FeatureLine(
                      icon: Icons.equalizer,
                      text: 'Phân tích kỹ năng chơi nhạc',
                      color: const Color(0xFF85CFFF),
                    ),
                    const SizedBox(height: 10),
                    _FeatureLine(
                      icon: Icons.cloud_outlined,
                      text: 'Thư viện bài hát cao cấp',
                      color: const Color(0xFF85CFFF),
                    ),
                    const SizedBox(height: 10),
                    _FeatureLine(
                      icon: Icons.self_improvement,
                      text: 'Chế độ luyện tập thông minh',
                      color: const Color(0xFF85CFFF),
                    ),
                  ] else ...[
                    _FeatureLine(
                      icon: Icons.check_circle_outline,
                      text: 'Tất cả các tính năng cơ bản',
                      color: const Color(0xFFFFB77D),
                    ),
                    const SizedBox(height: 10),
                    _FeatureLine(
                      icon: Icons.check_circle_outline,
                      text: 'Thư viện bài học cơ bản',
                      color: const Color(0xFFFFB77D),
                    ),
                    const SizedBox(height: 10),
                    _FeatureLine(
                      icon: Icons.check_circle_outline,
                      text: 'Chế độ luyện tập cơ bản',
                      color: const Color(0xFFFFB77D),
                    ),
                    const SizedBox(height: 10),
                    _FeatureLine(
                      icon: Icons.close,
                      text: 'Các tính năng luyện tập thông minh',
                      color: const Color(0xFF7B7672),
                      struck: true,
                    ),
                  ],
                  const SizedBox(height: 26),
                  Center(
                    child: GestureDetector(
                      onTap: onActionTap,
                      child: Container(
                        width: 161,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFF363636)
                              : const Color(0xFFF97F06),
                          borderRadius: BorderRadius.circular(99),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF5D5E62)
                                : const Color(0xFFF97F06),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          isCurrent ? 'HIỆN TẠI' : 'ĐĂNG KÝ',
                          style: GoogleFonts.plusJakartaSans(
                            color: isCurrent
                                ? const Color(0xFFE5E2E1)
                                : const Color(0xFF2D2D2D),
                            fontSize: 19 * 0.7,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
              if (isMaestro)
                Positioned(
                  top: -2,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      width: 111,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFB77D),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'ĐỀ XUẤT',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF1F1F1F),
                          fontSize: 16 * 0.7,
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
    );
  }
}

class _FeatureLine extends StatelessWidget {
  const _FeatureLine({
    required this.icon,
    required this.text,
    required this.color,
    this.struck = false,
  });

  final IconData icon;
  final String text;
  final Color color;
  final bool struck;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.plusJakartaSans(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              decoration: struck ? TextDecoration.lineThrough : null,
              decorationColor: color,
            ),
          ),
        ),
      ],
    );
  }
}
