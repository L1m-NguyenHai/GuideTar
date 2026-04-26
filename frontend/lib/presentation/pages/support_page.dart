import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:guidetar/data/backend_api.dart';
import 'package:guidetar/presentation/pages/support_account_faqs_page.dart';
import 'package:guidetar/presentation/pages/support_chat_page.dart';

import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  int _selectedNavIndex = 2;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _categories = const [];
  List<Map<String, dynamic>> _faqs = const [];

  @override
  void initState() {
    super.initState();
    _loadSupportData();
  }

  Future<void> _loadSupportData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        BackendApi.getSupportCategories(),
        BackendApi.getSupportFaqs(),
      ]);
      if (!mounted) {
        return;
      }
      setState(() {
        _categories = results[0];
        _faqs = results[1];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0E0E),
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 86, 20, 132),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _SearchBar(),
                  const SizedBox(height: 20),
                  Text(
                    'Danh mục câu hỏi',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFE5E2E1),
                      fontSize: 31 * 0.65,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_categories.isNotEmpty)
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _categories
                          .map(
                            (category) => _BackendCategoryChip(
                              label: (category['name'] ?? '').toString(),
                              onTap:
                                  (category['code'] ?? '').toString() ==
                                      'account'
                                  ? () {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              const SupportAccountFaqsPage(),
                                        ),
                                      );
                                    }
                                  : null,
                            ),
                          )
                          .toList(growable: false),
                    )
                  else
                    _CategoryGrid(
                      onAccountTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SupportAccountFaqsPage(),
                          ),
                        );
                      },
                    ),
                  const SizedBox(height: 24),
                  _SupportCtaCard(
                    onChatTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SupportChatPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 22),
                  Text(
                    'FAQ',
                    style: GoogleFonts.manrope(
                      color: const Color(0xFFE5E2E1),
                      fontSize: 31 * 0.65,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (_isLoading)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (_error != null)
                    Text(
                      _error!,
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFFFA366),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  else if (_faqs.isEmpty)
                    Text(
                      'Chưa có câu hỏi thường gặp.',
                      style: GoogleFonts.manrope(
                        color: const Color(0xFFB8ACA2),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    )
                  else
                    for (var i = 0; i < _faqs.length; i++) ...[
                      _FaqTile(
                        question: (_faqs[i]['question'] ?? '').toString(),
                        answer: (_faqs[i]['answer'] ?? '').toString(),
                      ),
                      if (i != _faqs.length - 1) const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
          ),
          const SafeArea(bottom: false, child: _TopBar()),
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
  const _TopBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      decoration: const BoxDecoration(color: Color.fromRGBO(0, 0, 0, 0.70)),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFFF97F06),
              size: 17,
            ),
          ),
          Expanded(
            child: Text(
              'Hỗ trợ',
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.4,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF97F06), width: 1.5),
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: Color(0xFFF97F06),
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1B1B),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color.fromRGBO(86, 67, 52, 0.30)),
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Color(0xFFA58C7B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bạn cần giúp đỡ điều gì?',
              style: GoogleFonts.manrope(
                color: const Color(0xFFA58C7B),
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  const _CategoryGrid({required this.onAccountTap});

  final VoidCallback onAccountTap;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.03,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      children: [
        _CategoryCard(
          label: 'Tài khoản',
          icon: Icons.account_circle_rounded,
          onTap: onAccountTap,
        ),
        const _CategoryCard(label: 'Thanh toán', icon: Icons.payment_rounded),
        const _CategoryCard(label: 'Lộ trình học', icon: Icons.map_rounded),
        const _CategoryCard(
          label: 'Báo lỗi',
          icon: Icons.warning_amber_rounded,
        ),
      ],
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.label, required this.icon, this.onTap});

  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E1E),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 138, 0, 0.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(icon, color: const Color(0xFFF7971A), size: 20),
              ),
              const SizedBox(height: 14),
              Text(
                label,
                style: GoogleFonts.manrope(
                  color: const Color(0xFFE5E2E1),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportCtaCard extends StatelessWidget {
  const _SupportCtaCard({required this.onChatTap});

  final VoidCallback onChatTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(53, 53, 52, 0.30),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color.fromRGBO(255, 255, 255, 0.05)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF201F1F),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFF8A051),
              size: 27,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Vẫn cần hỗ trợ?',
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFE5E2E1),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Đội ngũ chuyên gia của chúng tôi luôn sẵn\nsàng giải đáp mọi thắc mắc của bạn 24/7.',
            textAlign: TextAlign.center,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFA58C7B),
              fontSize: 14,
              height: 1.43,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: 200,
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF923E), Color(0xFFF97F06)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(255, 146, 62, 0.20),
                  blurRadius: 14,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: TextButton(
              onPressed: onChatTap,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF613100),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chat với CSKH',
                    style: GoogleFonts.plusJakartaSans(
                      color: const Color(0xFF613100),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFF613100),
                    size: 18,
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

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF201F1F),
          borderRadius: BorderRadius.circular(16),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 2),
          collapsedIconColor: const Color(0xFFAA9A8E),
          iconColor: const Color(0xFFAA9A8E),
          title: Text(
            question,
            style: GoogleFonts.plusJakartaSans(
              color: const Color(0xFFE5E2E1),
              fontSize: 16,
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
              child: Text(
                answer,
                style: GoogleFonts.plusJakartaSans(
                  color: const Color(0xFFB8ACA2),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BackendCategoryChip extends StatelessWidget {
  const _BackendCategoryChip({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color.fromRGBO(86, 67, 52, 0.3)),
        ),
        child: Text(
          label,
          style: GoogleFonts.manrope(
            color: const Color(0xFFE5E2E1),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
