/* ---- Lista prodotti per categoria: filtra e mostra ProductCard con descrizione posizionabile ---- */
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

  /* ---- Mappa la categoria al posizionamento della descrizione nella card ---- */
  DescriptionPlacement _placementForCategory(String cat) {
    switch (cat) {
      case 'fritti':
        return DescriptionPlacement.underPrice;
      case 'carne':
        return DescriptionPlacement.underTitle;
      case 'bevande':
        return DescriptionPlacement.none;
      case 'dolci':
        return DescriptionPlacement.none;
      case 'panini':
        return DescriptionPlacement.underTitle;
      default:
        return DescriptionPlacement.underTitle;
    }
  }

  @override
  Widget build(BuildContext context) {
    /* ---- Carica l’intero menù ---- */
    final future = MenuRepo.load();

    return Scaffold(
      appBar: AppBar(title: Text(title), centerTitle: true),

      /* ---- FutureBuilder: gestisce loading/errore/dati ---- */
      body: FutureBuilder<List<MenuItem>>(
        future: future,
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Errore nel caricamento: ${snap.error}'));
          }

          /* ---- Filtra gli elementi per categoria normalizzata ---- */
          final all = snap.data ?? const <MenuItem>[];
          final cat = category.trim().toLowerCase();
          final items = all.where((e) => e.category == cat).toList(growable: false);

          if (items.isEmpty) {
            return const Center(child: Text('Nessun elemento disponibile'));
          }

          /* ---- Sceglie il layout descrizione in base alla categoria ---- */
          final placement = _placementForCategory(cat);

          /* ---- Lista di ProductCard con spaziatura verticale ---- */
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
