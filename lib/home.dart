import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMenu;
  const HomePage({super.key, required this.onOpenMenu});

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
                child: Image.asset(
                  'asset/home_image.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Menù', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: onOpenMenu,
                  icon: const Icon(Icons.menu),
                  label: Text(
                    'Vedi tutto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
