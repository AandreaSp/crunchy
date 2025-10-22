/* ---- Formatta un prezzo in euro con decimali piccoli e rialzati (stile apice) ---- */
import 'package:flutter/material.dart';

class EuroPrice extends StatelessWidget {
  final double value;
  final double fontSize;
  const EuroPrice({super.key, required this.value, this.fontSize = 20});

  @override
  Widget build(BuildContext context) {
    /* ---- Estrae parte intera e centesimi (sempre due cifre) ---- */
    final whole = value.truncate();
    final cents = ((value - whole) * 100).round().toString().padLeft(2, '0');

    /* ---- Composizione del testo: "€", parte intera e centesimi come apice ---- */
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontSize: fontSize,
              fontWeight: FontWeight.w700,
            ),
        children: [
          const TextSpan(text: '€ '),
          TextSpan(text: '$whole'),
          /* ---- Centesimi spostati in alto per effetto apice, mantenendo l'allineamento di baseline ---- */
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
