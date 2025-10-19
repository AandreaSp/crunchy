import 'package:flutter/material.dart';
import 'package:crunchy/pages/menu_list.dart';
import 'package:crunchy/widgets/review_card.dart';
import 'package:crunchy/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatelessWidget {
  final VoidCallback onOpenMenu;
  final VoidCallback onOpenLocation;

  const HomePage({
    super.key,
    required this.onOpenMenu,
    required this.onOpenLocation,
  });

  Future<void> _openUrl(String? url) async {
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo
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

              // Menù
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
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => MenuListPage(
                                category: c.name.toLowerCase(),
                                title: c.name,
                              ),
                            ),
                          );
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
                                backgroundColor: bg,
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

              const SizedBox(height: 10),

              // anteprima gps
              Padding(
                padding: const EdgeInsets.all(20),
                child: Material(
                  color: cs.surface,
                  borderRadius: BorderRadius.circular(16),
                  elevation: 2,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Image.asset('asset/mappa/map.png', fit: BoxFit.cover),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.25),
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
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Material(
                                    color: cs.primaryContainer,
                                    borderRadius: BorderRadius.circular(999),
                                    child: InkWell(
                                      onTap: onOpenLocation,
                                      borderRadius: BorderRadius.circular(999),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 30,
                                          vertical: 10,
                                        ),
                                        child: Text(
                                          'vicino a te',
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

              // notizie
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Text(
                  "Vuoi ingannare l'attesa?",
                  style: Theme.of(context,).textTheme.titleMedium,
                ),
              ),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: NewsService().fetchNews(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: Colors.red),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Errore notizie: ${snapshot.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                (context as Element).markNeedsBuild(),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    );
                  }
                  final articles = snapshot.data!;
                  if (articles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Text('Nessuna notizia disponibile.'),
                    );
                  }
                  return SizedBox(
                    height: 210,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: articles.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) {
                        final a = articles[i];
                        final img = a['urlToImage'] as String?;
                        final source = a['source']?['name'] ?? '';
                        final date = (a['publishedAt'] as String?)
                            ?.substring(0, 10)
                            .replaceAll('-', ' ');
                        final label = date != null ? '$source • $date' : source;

                        return GestureDetector(
                          onTap: () => _openUrl(a['url'] as String?),
                          child: Container(
                            width: 300,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: Stack(
                                fit: StackFit.expand,
                                children: [
                                  if (img != null)
                                    Image.network(img, fit: BoxFit.cover)
                                  else
                                    Container(color: cs.surfaceContainerHighest),
                                  Container(color: Colors.black26),
                                  Positioned(
                                    top: 12,
                                    left: 12,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white70,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        label,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 16,
                                    left: 12,
                                    right: 12,
                                    child: Text(
                                      a['title'] ?? '',
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                        height: 1.2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),

              // Recensioni
              const SizedBox(height: 20),
              ReviewCard(
                imageAsset: 'asset/recensioni/recensione.png',
                onPressed: () {
                  // schermata recensioni
                },
              ),

              const SizedBox(height: 10),
            ],
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
