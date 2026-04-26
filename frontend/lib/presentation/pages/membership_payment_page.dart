import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

enum _PaymentMethod { bank, qr }

class MembershipPaymentPage extends StatefulWidget {
  const MembershipPaymentPage({super.key});

  @override
  State<MembershipPaymentPage> createState() => _MembershipPaymentPageState();
}

class _MembershipPaymentPageState extends State<MembershipPaymentPage> {
  int _selectedNavIndex = 2;
  _PaymentMethod _method = _PaymentMethod.bank;
  bool _isPaying = false;

  final TextEditingController _cardController = TextEditingController(
    text: '4242  4242  4242',
  );
  final TextEditingController _expiryController = TextEditingController(
    text: '12/12',
  );
  final TextEditingController _cvvController = TextEditingController(
    text: '123',
  );

  @override
  void dispose() {
    _cardController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _showPendingDialog() async {
    if (_isPaying) {
      return;
    }
    setState(() {
      _isPaying = true;
    });
    Map<String, dynamic> payment;
    try {
      payment = await BackendApi.pay(
        amount: 600000,
        currency: 'VND',
        methodType: _method == _PaymentMethod.bank ? 'card' : 'qr',
      );
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isPaying = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
      return;
    }

    if (!mounted) {
      return;
    }

    final shouldShowSuccess = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => _PendingPaymentDialog(
        paymentCode: (payment['payment_code'] ?? '').toString(),
        amount:
            '${(payment['amount'] ?? 0).toString()} ${(payment['currency'] ?? 'VND').toString()}',
        method: _method == _PaymentMethod.bank ? 'Thẻ ngân hàng' : 'Mã QR',
      ),
    );

    if (!mounted || shouldShowSuccess != true) {
      if (mounted) {
        setState(() {
          _isPaying = false;
        });
      }
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => _SuccessPaymentDialog(
        paymentCode: (payment['payment_code'] ?? '').toString(),
        amount:
            '${(payment['amount'] ?? 0).toString()} ${(payment['currency'] ?? 'VND').toString()}',
        method: _method == _PaymentMethod.bank ? 'Thẻ ngân hàng' : 'Mã QR',
      ),
    );

    if (mounted) {
      setState(() {
        _isPaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111011),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(35, 84, 35, 164),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Text(
                    'BẠN ĐÃ CHỌN',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFF7A464),
                      fontSize: 20 * 0.5,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'MAESTRO',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 60 * 0.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3A2C23),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.workspace_premium_rounded,
                          color: Color(0xFFE6B385),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Khai phá toàn bộ tiềm năng của nhạc cụ của bạn\nvới bộ tính năng cao cấp của chúng tôi.',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFB2AFAA),
                      fontSize: 16 * 0.8,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2D32),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              '600.000 VNĐ',
                              style: GoogleFonts.plusJakartaSans(
                                color: Colors.white,
                                fontSize: 47 * 0.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              ' /năm',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFFF79633),
                                fontSize: 31 * 0.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF4A7892),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Text(
                                '-20%',
                                style: GoogleFonts.plusJakartaSans(
                                  color: const Color(0xFF8ED2FF),
                                  fontSize: 13 * 0.8,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFFB1AEAA),
                              fontSize: 13 * 0.8,
                            ),
                            children: const [
                              TextSpan(
                                text: 'Đơn hàng sẽ tự động thanh toán vào ',
                              ),
                              TextSpan(
                                text: '06/06/2027',
                                style: TextStyle(color: Color(0xFFF79633)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E2D32),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Xác nhận đơn hàng',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 45 * 0.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _MethodButton(
                                label: 'Thẻ ngân hàng',
                                icon: Icons.credit_card_rounded,
                                selected: _method == _PaymentMethod.bank,
                                onTap: () {
                                  setState(() {
                                    _method = _PaymentMethod.bank;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _MethodButton(
                                label: 'Mã QR',
                                icon: Icons.qr_code_rounded,
                                selected: _method == _PaymentMethod.qr,
                                onTap: () {
                                  setState(() {
                                    _method = _PaymentMethod.qr;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        if (_method == _PaymentMethod.bank) ...[
                          const _InputLabel('Mã số thẻ'),
                          const SizedBox(height: 8),
                          _PaymentInput(controller: _cardController),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _InputLabel('Ngày hết hạn'),
                                    const SizedBox(height: 8),
                                    _PaymentInput(
                                      controller: _expiryController,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _InputLabel('CVV'),
                                    const SizedBox(height: 8),
                                    _PaymentInput(controller: _cvvController),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                'https://api.qrserver.com/v1/create-qr-code/?size=225x225&data=GuideTar-PAY-7XQ4-92LM-3K8V',
                                width: 225,
                                height: 225,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF3A393E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              _TotalLine(
                                label: 'Gói MAESTRO ( 1 năm )',
                                value: '756.000 VNĐ',
                                labelColor: const Color(0xFFA98F77),
                                valueColor: const Color(0xFFE4E3E1),
                              ),
                              const SizedBox(height: 8),
                              _TotalLine(
                                label: 'Giảm 20%',
                                value: '-156.000VNĐ',
                                labelColor: const Color(0xFF7CCBFF),
                                valueColor: const Color(0xFF7CCBFF),
                                icon: Icons.local_offer_outlined,
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'TỔNG TIỀN',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.plusJakartaSans(
                                        color: const Color(0xFFE5E2E0),
                                        fontSize: 50 * 0.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        '600.000 VNĐ',
                                        style: GoogleFonts.plusJakartaSans(
                                          color: const Color(0xFFF79633),
                                          fontSize: 45 * 0.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: SizedBox(
                      width: 179,
                      height: 41,
                      child: ElevatedButton(
                        onPressed: _showPendingDialog,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF79633),
                          foregroundColor: const Color(0xFF2A2D30),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          _isPaying ? 'ĐANG XỬ LÝ...' : 'THANH TOÁN',
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Bằng cách nhấn "Đăng ký ngay", bạn đồng ý với Điều khoản\ndịch vụ của chúng tôi.\nCó thể hủy bất cứ lúc nào. Hoàn tiền trong 7 ngày.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF8E8C88),
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(bottom: false, child: _PaymentTopBar()),
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

class _PaymentTopBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF131313),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(255, 140, 0, 0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).maybePop(),
            behavior: HitTestBehavior.opaque,
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFFFB77D),
              size: 16,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'THANH TOÁN',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFFFFB77D),
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.7,
              ),
            ),
          ),
          const Icon(Icons.music_note, color: Color(0xFFF79633), size: 18),
          const SizedBox(width: 8),
          Text(
            'GuideTar',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF4F4F5),
              fontSize: 20,
              fontWeight: FontWeight.w700,
              letterSpacing: -1,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingPaymentDialog extends StatefulWidget {
  const _PendingPaymentDialog({
    required this.paymentCode,
    required this.amount,
    required this.method,
  });

  final String paymentCode;
  final String amount;
  final String method;

  @override
  State<_PendingPaymentDialog> createState() => _PendingPaymentDialogState();
}

class _PendingPaymentDialogState extends State<_PendingPaymentDialog> {
  int _secondsLeft = 3;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsLeft <= 1) {
        timer.cancel();
        Navigator.of(context).pop(true);
        return;
      }

      setState(() {
        _secondsLeft -= 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A332F), Color(0xFF050709)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.45),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF7CCBFF),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF65839A), width: 2),
              ),
              child: const Icon(
                Icons.access_time_filled_rounded,
                color: Color(0xFF2E2F33),
                size: 54,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Giao dịch đang chờ xử lý',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 35 * 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Tự động xác nhận sau ${_secondsLeft}s',
              style: GoogleFonts.plusJakartaSans(
                color: const Color(0xFF8E8C88),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 24),
            _InfoLine(label: 'Mã thanh toán:', value: widget.paymentCode),
            const SizedBox(height: 12),
            _InfoLine(label: 'Số tiền:', value: widget.amount),
            const SizedBox(height: 12),
            _InfoLine(label: 'Phương thức:', value: widget.method),
            const SizedBox(height: 26),
            SizedBox(
              width: 99,
              height: 36,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF79633),
                  foregroundColor: const Color(0xFF292B2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  'Trở lại',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17 * 0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessPaymentDialog extends StatelessWidget {
  const _SuccessPaymentDialog({
    required this.paymentCode,
    required this.amount,
    required this.method,
  });

  final String paymentCode;
  final String amount;
  final String method;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 26),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3A332F), Color(0xFF050709)],
          ),
          boxShadow: const [
            BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.45),
              blurRadius: 24,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: const Color(0xFF00A991),
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF2E7D72), width: 2),
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Color(0xFF2E2F33),
                size: 56,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'Thanh toán thành công!',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 35 * 0.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            _InfoLine(label: 'Mã thanh toán:', value: paymentCode),
            const SizedBox(height: 12),
            _InfoLine(label: 'Số tiền:', value: amount),
            const SizedBox(height: 12),
            _InfoLine(label: 'Phương thức:', value: method),
            const SizedBox(height: 26),
            SizedBox(
              width: 99,
              height: 36,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF79633),
                  foregroundColor: const Color(0xFF292B2D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.zero,
                  elevation: 0,
                ),
                child: Text(
                  'Trở lại',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 17 * 0.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodButton extends StatelessWidget {
  const _MethodButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 43,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: selected ? const Color(0xFF3A393D) : const Color(0xFF4A4A4E),
          border: Border.all(
            color: selected ? const Color(0xFFF79633) : Colors.transparent,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFFF79633)
                  : const Color(0xFF8E8B88),
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.plusJakartaSans(
                color: selected
                    ? const Color(0xFFE8E7E6)
                    : const Color(0xFF8E8B88),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: const Color(0xFFC8A98A),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _PaymentInput extends StatelessWidget {
  const _PaymentInput({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 59,
      decoration: BoxDecoration(
        color: const Color(0xFF101113),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: const Color(0xFF6A6762), width: 1.5),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      alignment: Alignment.centerLeft,
      child: TextField(
        controller: controller,
        style: GoogleFonts.plusJakartaSans(
          color: Colors.white,
          fontSize: 18 * 0.8,
        ),
        decoration: const InputDecoration(
          border: InputBorder.none,
          isCollapsed: true,
        ),
      ),
    );
  }
}

class _TotalLine extends StatelessWidget {
  const _TotalLine({
    required this.label,
    required this.value,
    required this.labelColor,
    required this.valueColor,
    this.icon,
  });

  final String label;
  final String value;
  final Color labelColor;
  final Color valueColor;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, size: 14, color: labelColor),
          const SizedBox(width: 6),
        ],
        Expanded(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.plusJakartaSans(
              color: labelColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.right,
            style: GoogleFonts.plusJakartaSans(
              color: valueColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }
}
