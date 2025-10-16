import 'package:flutter/material.dart';
import 'euro_price.dart';

enum DescriptionPlacement { none, underTitle, underPrice }

class ProductCard extends StatelessWidget {
  final String imageAsset;
  final String title;
  final double price;
  final String? description; 
  final VoidCallback? onTap;
  final double aspectRatio;
  final DescriptionPlacement placement; 

  const ProductCard({
    super.key,
    required this.imageAsset,
    required this.title,
    required this.price,
    this.description,
    this.onTap,
    this.aspectRatio = 16 / 9,
    this.placement = DescriptionPlacement.underTitle,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasDesc = description != null && description!.trim().isNotEmpty;

    // Eventuale descrizione sotto il titolo
    Widget buildTitleBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (hasDesc && placement == DescriptionPlacement.underTitle)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                description!.trim(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.left,
              ),
            ),
        ],
      );
    }

    // Eventuale descrizione sotto il prezzo
    Widget buildPriceBlock() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          EuroPrice(value: price),
          if (hasDesc && placement == DescriptionPlacement.underPrice)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                description!.trim(),
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.right,
              ),
            ),
        ],
      );
    }

    final core = Ink(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            blurRadius: 8,
            offset: Offset(0, 4),
            color: Colors.black12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: aspectRatio,
              child: Image.asset(imageAsset, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(child: buildTitleBlock()),
                const SizedBox(width: 12),
                buildPriceBlock(),
              ],
            ),
          ),
        ],
      ),
    );

    if (onTap == null) return core;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: core,
    );
  }
}
