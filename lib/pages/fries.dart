import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../data/menu_repo.dart';
import '../models/menu_item.dart';

class FriesPage extends StatelessWidget {
  const FriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = MenuRepo.load();

    return Scaffold(
      appBar: AppBar(title: const Text('Fritti'), centerTitle: true),
      body: FutureBuilder<List<MenuItem>>(
        future: repo,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore nel caricamento: ${snap.error}'));
          }
          final all = snap.data ?? const <MenuItem>[];
          final items = all.where((e) => e.category == 'fritti').toList(growable: false);
          
          if (items.isEmpty) {
            return const Center(child: Text('Nessun elemento disponibile'));
          }
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
                );
              },
            ),
          );
        },
      ),
    );
  }
}