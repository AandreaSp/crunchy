/* ---- Card di categoria tappabile con immagine (ratio configurabile) e titolo centrato ---- */
import 'package:flutter/material.dart';

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final VoidCallback onTap;
  final double aspectRatio;

  const CategoryCard({
    super.key,
    required this.title,
    required this.imageAsset,
    required this.onTap,
    this.aspectRatio = 16 / 9,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    /* ---- Contenitore cliccabile con ripple + styling base (angoli arrotondati, ombra) ---- */
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(blurRadius: 8, offset: Offset(0, 4), color: Colors.black12),
          ],
        ),

        /* ---- Layout verticale: immagine in alto (ritagliata) + titolo in basso ---- */
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            /* ---- Immagine con ClipRRect e AspectRatio per mantenere le proporzioni ---- */
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: aspectRatio,
                child: Image.asset(imageAsset, fit: BoxFit.cover),
              ),
            ),

            /* ---- Titolo maiuscolo centrato, con ellissi su 2 righe ---- */
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
