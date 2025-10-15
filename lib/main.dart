import 'package:flutter/material.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/theme.dart';

void main() => runApp(const CrunchyApp());

class CrunchyApp extends StatelessWidget {
  const CrunchyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.app, 
      home: const CrunchyBottomBar()
    );
  }
}
