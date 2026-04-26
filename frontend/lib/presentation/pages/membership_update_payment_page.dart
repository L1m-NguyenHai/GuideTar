import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:guidetar/presentation/pages/support_page.dart';
import 'package:guidetar/presentation/widgets/home_bottom_navbar.dart';

class MembershipUpdatePaymentPage extends StatefulWidget {
  const MembershipUpdatePaymentPage({super.key});

  @override
  State<MembershipUpdatePaymentPage> createState() => _MembershipUpdatePaymentPageState();
}

class _MembershipUpdatePaymentPageState extends State<MembershipUpdatePaymentPage> {
  int _selectedNavIndex = 2;

  void _onNavChanged(int index) {
    if (index == 0) {
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    setState(() {
      _selectedNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF111011),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 84, 24, 126),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: double.infinity,
                    height: 176,
                    padding: const EdgeInsets.fromLTRB(20, 25, 20, 19),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          Color.fromRGBO(40, 117, 164, 0.8),
                          Color.fromRGBO(51, 163, 235, 0.8),
                        ],
                        stops: [0.33, 0.84],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'VISA',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 36 / 1.5,
                            fontWeight: FontWeight.w800,
                            height: 22.5 / 24,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '.... .... .... 1234',
                          style: GoogleFonts.plusJakartaSans(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            height: 36 / 24,
                          ),
                        ),
                        const Spacer(),
                        const Row(
                          children: [
                            Expanded(
                              child: _CardMeta(label: 'CARD HOLDER', value: 'Hy'),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: _CardMeta(label: 'EXPIRES', value: '09/06'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 34),
                  const _InputLabel('Tên chủ sở hữu'),
                  const SizedBox(height: 16),
                  const _PaymentInput(hint: 'Chau Quang Huy'),
                  const SizedBox(height: 28),
                  const _InputLabel('Số thẻ'),
                  const SizedBox(height: 16),
                  const _PaymentInput(
                    hint: '0000 0000 0000 0000',
                    trailingIcon: Icons.credit_card,
                  ),
                  const SizedBox(height: 28),
                  Row(
                    children: const [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InputLabel('Ngày hết hạn (MM/YY)'),
                            SizedBox(height: 16),
                            _PaymentInput(hint: 'MM/YY'),
                          ],
                        ),
                      ),
                      SizedBox(width: 52),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InputLabel('CVV'),
                            SizedBox(height: 16),
                            _PaymentInput(hint: '1234'),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 39),
                  Center(
                    child: SizedBox(
                      width: 192,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: const Color(0xFF2D2D2D),
                          elevation: 0,
                          shadowColor: const Color.fromRGBO(255, 183, 125, 0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(22),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                        child: Text(
                          'Cập nhật',
                          style: GoogleFonts.manrope(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                            height: 34 / 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Text(
                      'Bạn đang gặp sự cố ?',
                      style: GoogleFonts.manrope(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 1,
                        height: 36 / 14,
                      ),
                    ),
                  ),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SupportPage()),
                        );
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Text(
                        'LIÊN HỆ NGAY',
                        style: GoogleFonts.manrope(
                          color: const Color(0xFFFF923E),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1,
                          height: 36 / 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF131313),
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 14),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).maybePop(),
                      behavior: HitTestBehavior.opaque,
                      child: const SizedBox(
                        width: 16,
                        height: 16,
                        child: Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFFFFB77D),
                          size: 16,
                        ),
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
                          height: 20 / 14,
                        ),
                      ),
                    ),
                    const Icon(Icons.music_note, color: Color(0xFFF97316), size: 18),
                    const SizedBox(width: 8),
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
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: HomeBottomNavbar(
                  selectedIndex: _selectedNavIndex,
                  onChanged: _onNavChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CardMeta extends StatelessWidget {
  const _CardMeta({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.plusJakartaSans(
            color: const Color(0xFFDFAC06),
            fontSize: 8,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.plusJakartaSans(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

class _InputLabel extends StatelessWidget {
  const _InputLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.manrope(
        color: const Color(0xFFFAC38A),
        fontSize: 11,
        letterSpacing: 1,
        height: 36 / 11,
      ),
    );
  }
}

class _PaymentInput extends StatelessWidget {
  const _PaymentInput({required this.hint, this.trailingIcon});

  final String hint;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 41,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 19),
      decoration: BoxDecoration(
        color: const Color.fromRGBO(217, 217, 217, 0.24),
        border: Border.all(color: const Color.fromRGBO(252, 214, 176, 0.25)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: GoogleFonts.manrope(
                color: const Color.fromRGBO(255, 255, 255, 0.23),
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
                height: 36 / 12,
              ),
            ),
          ),
          if (trailingIcon != null) Icon(trailingIcon, color: const Color(0xFFFAC38A), size: 21),
        ],
      ),
    );
  }
}
