/* ---- Home: logo, carosello menù, anteprima mappa, notizie e recensioni ---- */
import 'package:flutter/material.dart';
import 'package:crunchy/widgets/review_card.dart';
import 'package:crunchy/widgets/review_sheet.dart';
import 'package:crunchy/widgets/menu_carousel.dart';
import 'package:crunchy/widgets/news_strip.dart';

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

    /* ---- Scaffold con scroll: blocchi verticali (logo, menù, mappa, notizie, recensioni) ---- */
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              /* ---- Logo in alto ---- */
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

              /* ---- Intestazione sezione Menù + azione "Vedi tutto" ---- */
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
              

              /* ---- Carosello categorie menù ---- */
              const MenuCarousel(),
              const SizedBox(height: 10),

              /* ---- Anteprima con pulsante per aprire la sezione GPS ---- */
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

              /* ---- Widget notizie ---- */
              const NewsStrip(),

              /* ---- Card recensioni con bottom sheet per lasciare feedback ---- */
              const SizedBox(height: 10),
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
                        content: const Text(
                          'E grazie mille per la cortese disponibiltà',
                        ),
                      ),
                    );
                  }
                },
              ),

              /* ---- Spaziatura finale ---- */
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
