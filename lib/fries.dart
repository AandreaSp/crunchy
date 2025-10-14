import 'package:flutter/material.dart';
import 'widgets/product_card.dart';

class FriesPage extends StatelessWidget {
  const FriesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <FriesItem>[
      FriesItem('PATATINE FRITTE', 3.50, 'porzione', 'asset/images/menu_fritti.jpg'),
      FriesItem('PATATINE CHEDDAR E BACON', 5.00, 'porzione', 'asset/images/fries/patatine_piene.png'),
      FriesItem('MOZZARELLINE', 4.00, '6 per porzione', 'asset/images/fries/mozzarelline.png'),
      FriesItem('CROCCHÈ', 2.50, 'porzione', 'asset/images/fries/crocche.png'),
      FriesItem('ALETTE DI POLLO', 4.50, '5 per porzione', 'asset/images/fries/wings.png'),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Fritti'), centerTitle: true),
      body: Padding(
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
              meta: it.unit,
            );
          },
        ),
      ),
    );
  }
}

class FriesItem {
  final String title;
  final double price;
  final String unit;
  final String image;
  FriesItem(this.title, this.price, this.unit, this.image);
}
