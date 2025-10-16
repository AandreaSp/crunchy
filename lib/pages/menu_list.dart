import 'package:flutter/material.dart';
import '../data/menu_repo.dart';
import '../models/menu_item.dart';
import '../widgets/product_card.dart';

class MenuListPage extends StatelessWidget {
  final String category;
  final String title;

  const MenuListPage({
    super.key,
    required this.category,
    required this.title,
  });

  DescriptionPlacement _placementForCategory(String cat) {
    switch (cat) {
      case 'fritti':
        return DescriptionPlacement.underPrice;
      case 'carne':
        return DescriptionPlacement.underTitle;
      case 'bevande':
        return DescriptionPlacement.none;
      case 'dolci':
      case 'panini':
        return DescriptionPlacement.underTitle;
      default:
        return DescriptionPlacement.underTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final future = MenuRepo.load();

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: FutureBuilder<List<MenuItem>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore nel caricamento: ${snap.error}'));
          }

          final all = snap.data ?? const <MenuItem>[];
          final cat = category.trim().toLowerCase();
          final items = all.where((e) => e.category == cat).toList(growable: false);

          if (items.isEmpty) {
            return const Center(child: Text('Nessun elemento disponibile'));
          }

          final placement = _placementForCategory(cat);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final it = items[i];
                return ProductCard(
                  imageAsset: it.image,
                  title: it.title,
                  price: it.price,
                  description: it.description,
                  placement: placement,
                );
              },
            ),
          );
        },
      ),
    );
  }
}
