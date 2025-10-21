import 'package:flutter/material.dart';
import 'package:crunchy/widgets/review_card.dart';
import 'package:crunchy/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crunchy/widgets/review_sheet.dart';
import 'package:crunchy/widgets/menu_carousel.dart';

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

              // Categorie — Carousel (1 elemento per volta)
              const MenuCarousel(),
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
                                    Container(
                                      color: cs.surfaceContainerHighest,
                                    ),
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
                        contentTextStyle: Theme.of(
                          context,
                        ).textTheme.bodyMedium,
                        title: const Text('Grazie per averci scelto!'),
                        content: const Text(
                          'E grazie mille per la cortese disponibiltà',
                        ),
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
