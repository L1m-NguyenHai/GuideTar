import 'package:flutter/material.dart';
import 'package:guidetar/presentation/pages/login_page.dart';
import 'package:guidetar/presentation/pages/opening_animation_page.dart';

class AppRootPage extends StatefulWidget {
  const AppRootPage({super.key});

  @override
  State<AppRootPage> createState() => _AppRootPageState();
}

class _AppRootPageState extends State<AppRootPage> with WidgetsBindingObserver {
  bool _showIntro = true;
  bool _wentBackground = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _wentBackground = true;
      return;
    }

    if (state == AppLifecycleState.resumed && _wentBackground) {
      _wentBackground = false;
      if (mounted) {
        setState(() {
          _showIntro = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showIntro) {
      return OpeningAnimationPage(
        onCompleted: () {
          if (!mounted) {
            return;
          }
          setState(() {
            _showIntro = false;
          });
        },
      );
    }

    return const LoginPage();
  }
}
