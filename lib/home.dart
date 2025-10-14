import 'package:flutter/material.dart';
import 'fries.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMenu;
  const HomePage({super.key, required this.onOpenMenu});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(30),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'asset/images/home_image.png',
                  height: 200,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Menù', style: Theme.of(context).textTheme.titleLarge),
                TextButton.icon(
                  onPressed: onOpenMenu,
                  icon: const Icon(Icons.menu),
                  label: Text(
                    'Vedi tutto',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
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
                        if (c.name.toLowerCase() == 'fritti') {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const FriesPage()),
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
                              backgroundColor: Color.fromARGB(255, 255, 239, 214),
                              backgroundImage: AssetImage(c.imagePath),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color.fromARGB(255, 91, 61, 63),
                                  fontWeight: FontWeight.w900,
                                ),
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
          ],
        ),
      ),
    );
  }
}

class FoodCategory {
  final String name;
  final String imagePath;
  final bool selected;
  const FoodCategory(this.name, this.imagePath, {this.selected = false});
}

const categories = <FoodCategory>[
  FoodCategory('Panini', 'asset/images/menu_panini.jpg', selected: true),
  FoodCategory('Fritti', 'asset/images/menu_fritti.jpg'),
  FoodCategory('Carne', 'asset/images/menu_carne.jpg'),
];
