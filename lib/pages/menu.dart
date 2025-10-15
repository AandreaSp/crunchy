import 'package:flutter/material.dart';
import '../widgets/category_card.dart';
import '../data/menu_repository.dart';
import '../models/menu_category.dart';
import 'fries.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MenuCategoriesRepo.load();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<MenuCategory>>(
          future: repo,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(child: Text('Errore nel caricamento: ${snap.error}'));
            }
            final categories = snap.data ?? const <MenuCategory>[];
            if (categories.isEmpty) {
              return const Center(child: Text('Nessuna categoria disponibile'));
            }
            return ListView.separated(
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, i) {
                final c = categories[i];
                return CategoryCard(
                  title: c.title,
                  imageAsset: c.imageAsset,
                  onTap: () {
                    if (c.title.toUpperCase() == 'FRITTI') {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const FriesPage()),
                      );
                    }
                    // TODO: aggiungere PANINI, CARNE, DOLCI e BEVANDE
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
