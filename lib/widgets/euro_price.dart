import 'package:flutter/material.dart';

class EuroPrice extends StatelessWidget {
  final double value;
  final double fontSize; // opzionale per varianti
  const EuroPrice({super.key, required this.value, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    final whole = value.truncate();
    final cents = ((value - whole) * 100).round().toString().padLeft(2, '0');

    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
        children: [
          const TextSpan(text: '€ '),
          TextSpan(text: '$whole'),
          WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: Transform.translate(
              offset: const Offset(1, -6),
              child: Text(
                '.$cents',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
