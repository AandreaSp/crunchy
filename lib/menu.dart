import 'package:flutter/material.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <MenuCategory>[
      MenuCategory(title: 'FRITTI', imageAsset: 'asset/images/menu_fritti.jpg'),
      MenuCategory(title: 'PANINI', imageAsset: 'asset/images/menu_panini.jpg'),
      MenuCategory(title: 'CARNE', imageAsset: 'asset/images/menu_carne.jpg'),
      MenuCategory(title: 'DOLCI', imageAsset: 'asset/images/menu_dolci.jpg'),
      MenuCategory(
        title: 'BEVANDE',
        imageAsset: 'asset/images/menu_bevande.jpg',
      ),
    ];

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView.separated(
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16),
          itemBuilder: (context, i) {
            final c = categories[i];
            return SizedBox(
              height: 240, // opzionale: controlla l’altezza della card
              child: CategoryCard(category: c, onTap: () {}),
            );
          },
        ),
      ),
    );
  }
}

class MenuCategory {
  final String title;
  final String imageAsset;
  const MenuCategory({required this.title, required this.imageAsset});
}

class CategoryCard extends StatelessWidget {
  final MenuCategory category;
  final VoidCallback onTap;
  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
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
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: Image.asset(category.imageAsset, fit: BoxFit.cover),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: Text(
                  category.title.toUpperCase(),
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
