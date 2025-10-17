import 'package:crunchy/pages/menu_list.dart';
import 'package:flutter/material.dart';
import 'package:crunchy/widgets/review_card.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenLocation;
  const HomePage({
    super.key,
    required this.onOpenMenu,
    required this.onOpenLocation,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
                      Text(
                        'Menù',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
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
                          child: InkWell(
                            onTap: onOpenMenu,
                            borderRadius: BorderRadius.circular(14),
                            child: const SizedBox(
                              width: 56,
                              height: 56,
                              child: Icon(
                                Icons.chevron_right,
                                color: Color.fromARGB(255, 91, 61, 63),
                              ),
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
                            final name = c.name.trim().toLowerCase();
                            if (name == 'fritti') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MenuListPage(
                                    category: 'fritti',
                                    title: 'Fritti',
                                  ),
                                ),
                              );
                            } else if (name == 'panini') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MenuListPage(
                                    category: 'panini',
                                    title: 'Panini',
                                  ),
                                ),
                              );
                            } else if (name == 'carne') {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const MenuListPage(
                                    category: 'carne',
                                    title: 'Carne',
                                  ),
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
                                  backgroundColor: const Color.fromARGB(
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
                                    style: Theme.of(
                                      context,
                                    ).textTheme.titleSmall,
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
                              Image.asset(
                                'asset/mappa/map.png',
                                fit: BoxFit.cover,
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: cs.surface.withValues(alpha: 0.25),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 12,
                                top: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
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
                                      Material(
                                        color: cs.primaryContainer,
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        elevation:
                                            0, // opzionale, lasci la shadow sotto
                                        child: InkWell(
                                          onTap:
                                              onOpenLocation, // usa il callback per aprire la tab Location
                                          borderRadius: BorderRadius.circular(
                                            999,
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 30,
                                              vertical: 10,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const SizedBox(width: 8),
                                                Text(
                                                  'vicino a te',
                                                  style: Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                                ),
                                              ],
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
                // card recensioni
                const SizedBox(height: 12),
                ReviewCard(
                  imageAsset: 'asset/recensioni/recensione.png',
                  onPressed: () {
                    // schermata recensioni
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modello categorie
class FoodCategory {
  final String name;
  final String imagePath;
  const FoodCategory(this.name, this.imagePath);
}

const categories = <FoodCategory>[
  FoodCategory('Panini', 'asset/menu/panini/menu_panini.jpg'),
  FoodCategory('Fritti', 'asset/menu/fritti/menu_fritti.jpg'),
  FoodCategory('Carne', 'asset/menu/carne/menu_carne.jpg'),
];
