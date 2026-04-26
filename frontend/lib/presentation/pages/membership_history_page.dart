import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/support_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class MembershipHistoryPage extends StatefulWidget {
  const MembershipHistoryPage({super.key});

  @override
  State<MembershipHistoryPage> createState() => _MembershipHistoryPageState();
}

class _MembershipHistoryPageState extends State<MembershipHistoryPage> {
  int _selectedNavIndex = 2;
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _subscription;
  List<Map<String, dynamic>> _transactions = const [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
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
    return '${number.round()} $currency';
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
                  _HistoryHeaderCard(
                    nextPaymentDate: _formatDate(_subscription?['renew_at']),
                    planName: (_subscription?['plan_name'] ?? 'MEMBER')
                        .toString(),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _SummaryCard(
                          title: 'Tổng số tiền',
                          value: _formatMoney(
                            _transactions.fold<double>(
                              0,
                              (sum, tx) =>
                                  sum +
                                  (double.tryParse(
                                        (tx['amount'] ?? 0).toString(),
                                      ) ??
                                      0),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SummaryCard(
                          title: 'Tổng hoá đơn',
                          value: _transactions.length.toString(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const _SectionLabel('LỊCH  SỬ  THANH  TOÁN'),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Center(child: CircularProgressIndicator())
                  else if (_error != null)
                    Text(
                      _error!,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFA366),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (_transactions.isEmpty)
                    Text(
                      'Chưa có giao dịch thanh toán.',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFE5E2E1),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    for (var i = 0; i < _transactions.length; i++) ...[
                      _HistoryCard(
                        amount: _formatMoney(
                          _transactions[i]['amount'],
                          (_transactions[i]['currency'] ?? 'VND').toString(),
                        ),
                        date: _formatDate(_transactions[i]['created_at']),
                        id: (_transactions[i]['payment_code'] ?? '').toString(),
                        status: (_transactions[i]['status'] ?? '').toString(),
                        showActionIcon: true,
                      ),
                      if (i != _transactions.length - 1)
                        const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 24),
                  _SupportBlock(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const SupportPage()),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: _TopBar(
              title: 'Lịch sử giao dịch',
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

class _HistoryHeaderCard extends StatelessWidget {
  const _HistoryHeaderCard({
    required this.nextPaymentDate,
    required this.planName,
  });

  final String nextPaymentDate;
  final String planName;

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
        crossAxisAlignment: CrossAxisAlignment.end,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: 2),
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFF484848)],
              ),
            ),
            child: Text(
              planName.toUpperCase(),
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(169, 171, 179, 0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFF7D9BE),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: GoogleFonts.plusJakartaSans(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
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
    this.status,
    this.showActionIcon = false,
  });

  final String amount;
  final String date;
  final String id;
  final String? status;
  final bool showActionIcon;

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
          if (showActionIcon)
            const Padding(
              padding: EdgeInsets.only(right: 10),
              child: Icon(Icons.download_rounded, color: Color(0xFFBCBBBA)),
            ),
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
                    children: [
                      TextSpan(text: amount),
                      if (status != null)
                        TextSpan(
                          text: ' $status',
                          style: const TextStyle(color: Color(0xFF85CFFF)),
                        ),
                    ],
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

class _SupportBlock extends StatelessWidget {
  const _SupportBlock({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          child: Column(
            children: [
              Text(
                'Bạn đang gặp sự cố ?',
                style: GoogleFonts.plusJakartaSans(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'LIÊN HỆ NGAY',
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFF97F06),
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
