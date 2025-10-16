  import 'package:crunchy/pages/menu_list.dart';
  import 'package:flutter/material.dart';
  import '../widgets/category_card.dart';
  import '../data/card_menu_repo.dart';
  import '../models/card_menu_category.dart';

  class MenuPage extends StatelessWidget {
    const MenuPage({super.key});

    String? _mapTitleToCategory(String title) {
      final t = title.trim().toUpperCase();
      switch (t) {
        case 'FRITTI':
          return 'fritti';
        case 'PANINI':
          return 'panini';
        case 'CARNE':
          return 'carne';
        case 'DOLCI':
          return 'dolci';
        case 'BEVANDE':
          return 'bevande';
        default:
          return null;
      }
    }

    void _openCategory(BuildContext context, MenuCategory c) {
      final cat = _mapTitleToCategory(c.title);
      if (cat == null) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => MenuListPage(
            category: cat,
            title: c.title,
          ),
        ),
      );
    }

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
                    onTap: () => _openCategory(context, c),
                  );
                },
              );
            },
          ),
        ),
      );
    }
  }
