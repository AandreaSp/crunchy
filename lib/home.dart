import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Padding(
  padding: const EdgeInsets.all(30),
  child: ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: Image.asset('asset/home_image.png', height: 200, fit: BoxFit.cover),
  ),
)
          ],
        ),
      ),
    );
  }
}
