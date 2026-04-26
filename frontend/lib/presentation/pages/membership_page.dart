import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';

import 'package:guidetar/presentation/pages/membership_history_page.dart';
import 'package:guidetar/presentation/pages/membership_register_page.dart';
import 'package:guidetar/presentation/pages/membership_update_payment_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class MembershipPage extends StatefulWidget {
  const MembershipPage({super.key});

  @override
  State<MembershipPage> createState() => _MembershipPageState();
}

class _MembershipPageState extends State<MembershipPage> {
  int _selectedNavIndex = 2;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _loadBilling();
  }

  Future<void> _loadBilling() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        BackendApi.getBillingSubscription(),
        BackendApi.getBillingTransactions(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _subscription = results[0] as Map<String, dynamic>?;
        _transactions = results[1] as List<Map<String, dynamic>>;
      });
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = error.message;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatDate(dynamic value) {
    final parsed = DateTime.tryParse((value ?? '').toString());
    if (parsed == null) {
      return '--/--/----';
    }
    final d = parsed.toLocal();
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  String _formatMoney(dynamic amount, [String currency = 'VND']) {
    final number = amount is num
        ? amount.toDouble()
        : double.tryParse((amount ?? '').toString()) ?? 0;
    final intValue = number.round();
    return '${intValue.toString()} $currency';
  }

  Future<void> _showCancelDialog() async {
    final shouldCancel = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1D1D),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(249, 115, 22, 0.16),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFF9A14A),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Xác nhận huỷ gói?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Bạn có chắc muốn huỷ gói? Bạn sẽ mất quyền truy cập thư viện và các tính năng luyện tập, phân tích nâng cao.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFD7D4D2),
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFF97F06),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      elevation: 0,
                    ),
                    child: Text(
                      'Huỷ xác nhận',
                      style: GoogleFonts.plusJakartaSans(
                        color: const Color(0xFF2D2D2D),
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  child: Text(
                    'Quay lại',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFE5E2E1),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    if (!mounted || shouldCancel != true) {
      return;
    }

    try {
      final result = await BackendApi.cancelSubscription();
      if (!mounted) {
        return;
      }
      await showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (dialogContext) {
          return Dialog(
            backgroundColor: const Color(0xFF1E1D1D),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(133, 207, 255, 0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color(0xFF85CFFF),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Xác nhận huỷ thành công',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    (result['detail'] ?? '').toString(),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFD7D4D2),
                      fontSize: 14,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97F06),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        elevation: 0,
                      ),
                      child: Text(
                        'Quay lại',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFF2D2D2D),
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
      _loadBilling();
    } on ApiException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
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
              padding: const EdgeInsets.fromLTRB(24, 88, 24, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TRẠNG THÁI HIỆN TẠI',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFFFFB77D),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _isLoading
                              ? 'ĐANG TẢI...'
                              : (_subscription == null
                                    ? 'CHƯA CÓ\nGÓI'
                                    : 'ĐĂNG KÝ\n${((_subscription?['status'] ?? '').toString()).toUpperCase()}'),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 31,
                            fontWeight: FontWeight.w700,
                            height: 1.08,
                            letterSpacing: -0.75,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF97316), Color(0xFF484848)],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          (_subscription?['plan_name'] ?? 'MEMBER')
                              .toString()
                              .toUpperCase(),
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _NextPaymentCard(
                    nextPaymentDate: _formatDate(_subscription?['renew_at']),
                    onChangeTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MembershipRegisterPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('PHƯƠNG   THỨC   THANH   TOÁN'),
                  const SizedBox(height: 12),
                  _PaymentMethodCard(
                    onUpdateTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const MembershipUpdatePaymentPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  const _SectionLabel('CHI  TIẾT'),
                  const SizedBox(height: 12),
                  _BenefitCard(
                    title: 'Trạng thái gói',
                    status: (_subscription?['status'] ?? 'inactive')
                        .toString()
                        .toUpperCase(),
                    icon: Icons.analytics_outlined,
                  ),
                  const SizedBox(height: 12),
                  const _BenefitCard(
                    title: 'Thư  viện  bài  hát  cao  cấp',
                    status: 'HOẠT ĐỘNG',
                    icon: Icons.library_music_outlined,
                  ),
                  const SizedBox(height: 12),
                  const _BenefitCard(
                    title: 'Chế  độ  luyện  tập  thông  minh',
                    status: 'HOẠT ĐỘNG',
                    icon: Icons.auto_awesome_outlined,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: _SectionLabel('LỊCH  SỬ  THANH  TOÁN'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const MembershipHistoryPage(),
                            ),
                          );
                        },
                        child: Text(
                          'TOÀN BỘ',
                          style: GoogleFonts.plusJakartaSans(
                            color: const Color(0xFFDEC1AF),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  if (_error != null)
                    Text(
                      _error!,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFA366),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (_transactions.isEmpty)
                    Text(
                      'Chưa có giao dịch thanh toán.',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFDEC1AF),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else
                    for (
                      var i = 0;
                      i < (_transactions.length > 2 ? 2 : _transactions.length);
                      i++
                    ) ...[
                      _HistoryCard(
                        amount: _formatMoney(
                          _transactions[i]['amount'],
                          (_transactions[i]['currency'] ?? 'VND').toString(),
                        ),
                        date: _formatDate(_transactions[i]['created_at']),
                        id: (_transactions[i]['payment_code'] ?? '').toString(),
                      ),
                      if (i !=
                          (_transactions.length > 2
                              ? 1
                              : _transactions.length - 1))
                        const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: _showCancelDialog,
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(
                          color: Color.fromRGBO(255, 255, 255, 0.12),
                        ),
                        backgroundColor: const Color(0xFF201F1F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text(
                        'HUỶ ĐĂNG KÝ',
                        style: GoogleFonts.plusJakartaSans(
                          color: const Color(0xFFFFB08C),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: _TopBar(
              title: 'Đăng kí hội viên',
              onBackTap: () => Navigator.of(context).maybePop(),
            ),
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

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title, required this.onBackTap});

  final String title;
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
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: GoogleFonts.plusJakartaSans(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.75,
      ),
    );
  }
}

class _NextPaymentCard extends StatelessWidget {
  const _NextPaymentCard({
    required this.onChangeTap,
    required this.nextPaymentDate,
  });

  final VoidCallback onChangeTap;
  final String nextPaymentDate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 20, 20, 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: const LinearGradient(
          begin: Alignment(-0.2, 1.0),
          end: Alignment(1.0, -1.0),
          colors: [Color(0xFF545A5D), Color(0xFFFF6800)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'NGÀY THANH TOÁN TIẾP THEO',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              nextPaymentDate,
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.75,
              ),
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: onChangeTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(20),
                gradient: const LinearGradient(
                  colors: [Color(0xFFD2D2D2), Color(0xFF85CFFF)],
                ),
              ),
              child: Text(
                'THAY ĐỔI',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFF2D2D2D),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodCard extends StatelessWidget {
  const _PaymentMethodCard({required this.onUpdateTap});

  final VoidCallback onUpdateTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment(-0.2, 1.0),
          end: Alignment(1.0, -1.0),
          colors: [Color(0xFFF97316), Color(0xFF54595D)],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '.... .... ....',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.75,
                    height: 1.0,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'HY',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'HẾT HẠN: 20/11',
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onUpdateTap,
            behavior: HitTestBehavior.opaque,
            child: Column(
              children: [
                Text(
                  'CẬP NHẬT',
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFFCD6B0),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.credit_card,
                    color: Colors.white,
                    size: 21,
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

class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.title,
    required this.status,
    required this.icon,
  });

  final String title;
  final String status;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        gradient: const LinearGradient(
          begin: Alignment(-0.3, 1.0),
          end: Alignment(1.0, -1.0),
          colors: [
            Color.fromRGBO(51, 51, 51, 0.37),
            Color.fromRGBO(71, 70, 68, 0.37),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.plusJakartaSans(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.75,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  status,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFF85CFFF),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.75,
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: const Color(0xFFE7D6CA), size: 20),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.amount,
    required this.date,
    required this.id,
  });

  final String amount;
  final String date;
  final String id;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment(-0.2, 1.0),
          end: Alignment(1.0, -1.0),
          colors: [
            Color.fromRGBO(0, 0, 0, 0.37),
            Color.fromRGBO(71, 70, 68, 0.37),
          ],
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.plusJakartaSans(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    children: [TextSpan(text: amount)],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  id,
                  style: GoogleFonts.plusJakartaSans(
                    color: const Color(0xFFE5E2E1),
                    fontSize: 13,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.35,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(159, 159, 159, 0.26),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.receipt_long,
                  size: 18,
                  color: Color(0xFFE5E2E1),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
