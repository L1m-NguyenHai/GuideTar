import 'package:flutter/material.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/presentation/pages/app_root_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuideTar',
      theme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: const AppRootPage(),
    );
  }
}
