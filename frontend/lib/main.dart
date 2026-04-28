import 'package:flutter/material.dart';
import 'package:guidetar/config/theme.dart';
import 'package:guidetar/presentation/pages/app_root_page.dart';

void main() {
  runApp(const MyApp());
}

// ignore: library_private_types_in_public_api
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
