/* ---- Modello categoria per la pagina menù (titolo + asset immagine) ---- */
class MenuCategory {
  final String title;
  final String imageAsset;

  const MenuCategory({
    required this.title,
    required this.imageAsset,
  });

  /* ---- Costruttore da JSON (mappa -> istanza) ---- */
  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        title: json['title'] as String,
        imageAsset: json['imageAsset'] as String,
      );
}
