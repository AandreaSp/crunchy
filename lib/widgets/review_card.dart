import 'package:flutter/material.dart';

class ReviewCard extends StatelessWidget {
  final String imageAsset;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry margin;

  const ReviewCard({
    super.key,
    required this.imageAsset,
    required this.onPressed,
    this.margin = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Card(
      margin: margin,
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Container(
        color: cs.surface,
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, color: Color(0xFFF0B84B), size: 30),
                const SizedBox(width: 8),
                Icon(Icons.star, color: Color(0xFFF0B84B), size: 40),
                const SizedBox(width: 8),
                Icon(Icons.star, color: Color(0xFFF0B84B), size: 30),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              'Dacci la tua opinione',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 14),

            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(imageAsset, height: 140, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                elevation: 0,
                backgroundColor: cs.primaryContainer,
                foregroundColor: cs.onPrimaryContainer,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Scrivi recensione',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
