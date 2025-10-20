import 'package:flutter/material.dart';
import 'package:crunchy/pages/menu_list.dart';
import 'package:crunchy/widgets/review_card.dart';
import 'package:crunchy/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crunchy/widgets/review_sheet.dart';
import 'package:carousel_slider/carousel_slider.dart';

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

              // Menù + Vedi tutto
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
                      icon: const Icon(Icons.menu, size: 18),
                      label: Text(
                        'Vedi tutto',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Categorie — Hero Carousel
              const _MenuHeroCarousel(),
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
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Trova ristorante',
                                      style: Theme.of(context).textTheme.titleMedium,
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
                                          style: Theme.of(context).textTheme.titleMedium,
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 10),
                child: Text(
                  "Vuoi ingannare l'attesa?",
                  style: Theme.of(context).textTheme.titleMedium,
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
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                            onPressed: () => (context as Element).markNeedsBuild(),
                            icon: const Icon(Icons.refresh),
                          ),
                        ],
                      ),
                    );
                  }
                  final articles = snapshot.data!;
                  if (articles.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 6,
                                  offset: Offset(0, 4),
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
                onPressed: () async {
                  final confirmed = await openReviewSheet(context);
                  if (confirmed == true && context.mounted) {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        titleTextStyle: Theme.of(context).textTheme.titleMedium,
                        contentTextStyle: Theme.of(context).textTheme.bodyMedium,
                        title: const Text('Grazie per averci scelto!'),
                        content: const Text('E grazie mille per la cortese disponibiltà'),
                      ),
                    );
                  }
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

/* -------------------- WIDGET: Menu Hero Carousel -------------------- */

class _MenuHeroCarousel extends StatefulWidget {
  const _MenuHeroCarousel();

  @override
  State<_MenuHeroCarousel> createState() => _MenuHeroCarouselState();
}

class _MenuHeroCarouselState extends State<_MenuHeroCarousel> {
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      children: [
        CarouselSlider.builder(
          carouselController: _controller,
          itemCount: categories.length,
          itemBuilder: (context, i, _) {
            final c = categories[i];
            return GestureDetector(
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
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(c.imagePath, fit: BoxFit.cover),

                      // pannello chiaro a destra (effetto "vetrina")
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          width: 170,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                              colors: [
                                cs.surface.withValues(alpha: 0.95),
                                cs.surface.withValues(alpha: 0.65),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // titolo con stile titleSmall
                      Positioned(
                        right: 18,
                        top: 18,
                        child: Text(
                          c.name,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: cs.onSurface,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
          options: CarouselOptions(
            height: 190,
            viewportFraction: 0.9,
            enlargeCenterPage: true,
            enlargeFactor: 0.18,
            enableInfiniteScroll: false,
            padEnds: false,
            onPageChanged: (index, reason) => setState(() => _current = index),
          ),
        ),
        const SizedBox(height: 10),

        // puntini indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(categories.length, (i) {
            final selected = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: selected ? 18 : 6,
              decoration: BoxDecoration(
                color: selected ? cs.primary : cs.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/* -------------------- Modello categorie -------------------- */

class FoodCategory {
  final String name;
  final String imagePath;
  const FoodCategory(this.name, this.imagePath);
}

const categories = <FoodCategory>[
  FoodCategory("Panini", 'asset/menu/panini/crunchy.png'),
  FoodCategory("Carne", 'asset/menu/carne/fiorentina.png'),
  FoodCategory("Dolci", 'asset/menu/dolci/tiramisu.png'),
];
