import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:guidetar/presentation/pages/login_page.dart';

class OpeningAnimationPage extends StatefulWidget {
  const OpeningAnimationPage({super.key, this.onCompleted});

  final VoidCallback? onCompleted;

  @override
  State<OpeningAnimationPage> createState() => _OpeningAnimationPageState();
}

class _OpeningAnimationPageState extends State<OpeningAnimationPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          if (widget.onCompleted != null) {
            widget.onCompleted!();
            return;
          }

          Navigator.of(context).pushReplacement(
            PageRouteBuilder<void>(
              transitionDuration: const Duration(milliseconds: 450),
              pageBuilder: (buildContext, animation, secondaryAnimation) =>
                  const LoginPage(),
              transitionsBuilder:
                  (buildContext, animation, secondaryAnimation, child) {
                final offsetAnimation = Tween<Offset>(
                  begin: const Offset(1, 0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(
                    parent: animation,
                    curve: Curves.easeOutCubic,
                  ),
                );
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        }
      });
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const bgColor = Color(0xFF111011);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: 263.229,
            height: 81,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                final t = _controller.value;

                final phase1Opacity = _segmentOpacity(t, 0.00, 0.18, 0.34);
                final phase2Opacity = _segmentOpacity(t, 0.20, 0.38, 0.54);
                final finalPhaseOpacity = _fadeInOpacity(t, 0.44, 0.64);
                final textReveal =
                    Curves.easeOutCubic.transform(_normalized(t, 0.62, 0.98));
                final noteGlide =
                  Curves.easeInOutCubic.transform(_normalized(t, 0.54, 0.78));
                final noteLeft = 104 + (0 - 104) * noteGlide;

                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Opacity(
                      opacity: phase1Opacity,
                      child: SizedBox(
                        width: 263.229,
                        height: 75,
                        child: SvgPicture.asset('assets/icons/intro_phase_1.svg'),
                      ),
                    ),
                    Opacity(
                      opacity: phase2Opacity,
                      child: SizedBox(
                        width: 263.229,
                        height: 75,
                        child: SvgPicture.asset('assets/icons/intro_phase_2.svg'),
                      ),
                    ),
                    Opacity(
                      opacity: finalPhaseOpacity,
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: SizedBox(
                          width: 263.229,
                          height: 81,
                          child: Stack(
                            children: [
                              Positioned(
                                left: noteLeft,
                                bottom: 0,
                                child: SizedBox(
                                  width: 55,
                                  height: 75,
                                  child: SvgPicture.asset('assets/icons/intro_note.svg'),
                                ),
                              ),
                              Positioned(
                                left: 76,
                                bottom: 0,
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: textReveal,
                                    child: const SizedBox(
                                      width: 171,
                                      height: 81,
                                      child: Center(
                                        child: Text(
                                          'GuideTar',
                                          style: TextStyle(
                                            color: Color(0xFFF4F4F5),
                                            fontSize: 40,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: -1,
                                            height: 1.0,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  double _normalized(double t, double start, double end) {
    if (t <= start) {
      return 0;
    }
    if (t >= end) {
      return 1;
    }
    return (t - start) / (end - start);
  }

  double _segmentOpacity(double t, double appearStart, double fullAt, double fadeEnd) {
    if (t <= appearStart || t >= fadeEnd) {
      return 0;
    }
    if (t <= fullAt) {
      return Curves.easeOut.transform(_normalized(t, appearStart, fullAt));
    }
    return 1 - Curves.easeIn.transform(_normalized(t, fullAt, fadeEnd));
  }

  double _fadeInOpacity(double t, double start, double end) {
    return Curves.easeOutCubic.transform(_normalized(t, start, end));
  }
}
