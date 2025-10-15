import 'package:flutter/material.dart';
import 'fries.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMenu;
  const HomePage({super.key, required this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // immagine della home
            Padding(
              padding: const EdgeInsets.all(20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'asset/logo/home_image.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // anteprima menù
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Menù', style: Theme.of(context).textTheme.titleMedium),
                  TextButton.icon(
                    onPressed: onOpenMenu,
                    icon: const Icon(Icons.menu),
                    label: Text(
                      'Vedi tutto',
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Categorie
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: categories.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, i) {
                  if (i == categories.length) {
                    return Material(
                      color: const Color.fromARGB(255, 255, 239, 214),
                      borderRadius: BorderRadius.circular(14),
                      child: const SizedBox(
                        width: 56,
                        height: 56,
                        child: Icon(
                          Icons.chevron_right,
                          color: Color.fromARGB(255, 91, 61, 63),
                        ),
                      ),
                    );
                  }
                  final c = categories[i];
                  const bg = Color.fromARGB(255, 255, 239, 214);
                  return Material(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      onTap: () {
                        if (c.name.toLowerCase() == 'fritti') {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const FriesPage(),
                            ),
                          );
                        }
                      },
                      borderRadius: BorderRadius.circular(14),
                      child: SizedBox(
                        width: 160,
                        height: 56,
                        child: Row(
                          children: [
                            const SizedBox(width: 12),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Color.fromARGB(
                                255,
                                255,
                                239,
                                214,
                              ),
                              backgroundImage: AssetImage(c.imagePath),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // anteprima gps
            Padding(
              padding: const EdgeInsets.all(20),
              child: Material(
                color: cs.surface,
                borderRadius: BorderRadius.circular(16),
                elevation: 2,
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          // Background decorativo stile mappa
                          Image.asset(
                            'asset/mappa/map.png',
                            fit: BoxFit.cover,
                          ),
                          // Velo per migliorare il contrasto
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: cs.surface.withValues(alpha: 0.25),
                              ),
                            ),
                          ),
                          // Pin decorativo
                          Positioned(
                            left: 12,
                            top: 12,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 6,
                                    offset: Offset(0, 3),
                                    color: Colors.black26,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.gps_fixed,
                                color: cs.primary,
                                size: 18,
                              ),
                            ),
                          ),
                          // Pannello inferiore con titolo e "pulsante" grafico
                          Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              height: 72,
                              decoration: BoxDecoration(
                                color: cs.surface,
                                borderRadius: const BorderRadius.vertical(
                                  bottom: Radius.circular(16),
                                ),
                              ),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Trova ristorante',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  IgnorePointer(
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            color: Colors.black12,
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 35,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          'Vicino a te',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleMedium,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Modello categorie
class FoodCategory {
  final String name;
  final String imagePath;
  final bool selected;
  const FoodCategory(this.name, this.imagePath, {this.selected = false});
}

const categories = <FoodCategory>[
  FoodCategory('Panini', 'asset/menu/panini/menu_panini.jpg', selected: true),
  FoodCategory('Fritti', 'asset/menu/fritti/menu_fritti.jpg'),
  FoodCategory('Carne', 'asset/menu/carne/menu_carne.jpg'),
];
