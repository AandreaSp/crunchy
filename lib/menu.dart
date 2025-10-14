import 'package:flutter/material.dart';
import 'fries.dart';
import 'widgets/category_card.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = <MenuCategory>[
      MenuCategory(title: 'FRITTI', imageAsset: 'asset/images/menu_fritti.jpg'),
      MenuCategory(title: 'PANINI', imageAsset: 'asset/images/menu_panini.jpg'),
      MenuCategory(title: 'CARNE', imageAsset: 'asset/images/menu_carne.jpg'),
      MenuCategory(title: 'DOLCI', imageAsset: 'asset/images/menu_dolci.jpg'),
      MenuCategory(title: 'BEVANDE',imageAsset: 'asset/images/menu_bevande.jpg'),
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
               
              child: CategoryCard(
                title: c.title,
                imageAsset: c.imageAsset, 
                onTap: () {
                  if(c.title.toUpperCase() == 'FRITTI') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FriesPage()),
                    );
                  }
                }),
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