/* ---- Carosello di categorie con immagini: tap su una card -> apre la lista della categoria corrispondente ---- */
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:crunchy/pages/menu_list.dart';

class MenuCarousel extends StatefulWidget {
  const MenuCarousel({super.key});

  @override
  State<MenuCarousel> createState() => _MenuCarouselState();
}

class _MenuCarouselState extends State<MenuCarousel> {
  /* ---- Stato del carosello: controller per scorrere e indice pagina corrente ---- */
  final CarouselSliderController _controller = CarouselSliderController();
  int _current = 0;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    /* ---- Layout verticale: carosello a tutta larghezza + indicatori di pagina ---- */
    return Column(
      children: [
        /* ---- Carosello: card con immagine di sfondo, pannello/gradiente a destra e titolo; tap -> navigazione a MenuListPage ---- */
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: CarouselSlider.builder(
            carouselController: _controller,
            itemCount: _categories.length,
            itemBuilder: (context, i, _) {
              final c = _categories[i];
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
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(c.imagePath, fit: BoxFit.cover),

                        /* ---- Pannello “vetrina” con gradiente sul lato destro per migliorare la leggibilità del titolo ---- */
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

                        /* ---- Titolo della categoria in alto a destra ---- */
                        Positioned(
                          right: 18,
                          top: 18,
                          child: Text(
                            c.name,
                            textAlign: TextAlign.right,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
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
            /* ---- Opzioni del carosello: scorrimento a pagina intera, senza loop; aggiorna l’indicatore all’evento di cambio pagina ---- */
            options: CarouselOptions(
              height: 190,
              viewportFraction: 1.0,
              enlargeCenterPage: false,
              enableInfiniteScroll: false,
              padEnds: false,
              pageSnapping: true,
              onPageChanged: (index, reason) =>
                  setState(() => _current = index),
            ),
          ),
        ),
        const SizedBox(height: 10),

        /* ---- Indicatori animati dello stato del carosello (pallini) ---- */
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_categories.length, (i) {
            final selected = i == _current;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: selected ? 18 : 6,
              decoration: BoxDecoration(
                color: selected
                    ? cs.primary
                    : cs.primary.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ),
      ],
    );
  }
}

/* ---- Modello dati interno per rappresentare la categoria del menù ---- */
class _FoodCategory {
  final String name;
  final String imagePath;
  const _FoodCategory(this.name, this.imagePath);
}

/* ---- Dataset locale delle categorie mostrate nel carosello ---- */
const _categories = <_FoodCategory>[
  _FoodCategory("Panini", 'asset/menu/panini/crunchy.png'),
  _FoodCategory("Carne", 'asset/menu/carne/fiorentina.png'),
  _FoodCategory("Dolci", 'asset/menu/dolci/tiramisu.png'),
];
