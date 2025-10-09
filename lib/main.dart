import 'package:flutter/material.dart';
import 'bottom_bar.dart';

void main() => runApp(const CrunchyApp());

class CrunchyApp extends StatelessWidget {
  const CrunchyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.amber,
          brightness: Brightness.light,
        ),
      ),
      home: const CrunchyBottomBar(),
    );
  }
}
