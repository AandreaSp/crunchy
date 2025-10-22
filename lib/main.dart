/* ---- Entry point: avvio MaterialApp con tema e bottom bar come home ---- */
import 'package:flutter/material.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/theme.dart';

void main() => runApp(const CrunchyApp());

class CrunchyApp extends StatelessWidget {
  const CrunchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /* ---- Wrapper dell’app: titolo, tema e schermata iniziale ---- */
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Ristorante Crunchy',
      theme: AppTheme.app,
      home: const CrunchyBottomBar(),
    );
  }
}
