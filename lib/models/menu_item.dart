/* ---- Modello elemento di menù: titolo, prezzo, immagine, descrizione (opzionale) e categoria ---- */
class MenuItem {
  final String title;
  final double price;
  final String image;
  final String? description;
  final String category;

  const MenuItem({
    required this.title,
    required this.price,
    required this.image,
    this.description,
    required this.category,
  });

  /* ---- Costruttore da JSON con validazioni sui campi obbligatori ---- */
  factory MenuItem.fromJson(Map<String, dynamic> json) {
    /* ---- Estrae i raw values dal JSON ---- */
    final titleRaw = json['title'];
    final priceRaw = json['price'];
    final imageRaw = json['image'];
    final categoryRaw = json['category'];

    /* ---- Validazione campi obbligatori (tipo e non-vuoto) ---- */
    if (titleRaw is! String || titleRaw.trim().isEmpty) {
      throw ArgumentError('MenuItem: chiave "title" mancante o non valida');
    }
    if (priceRaw is! num) {
      throw ArgumentError('MenuItem: chiave "price" mancante o non valida');
    }
    if (imageRaw is! String || imageRaw.trim().isEmpty) {
      throw ArgumentError('MenuItem: chiave "image" mancante o non valida');
    }
    if (categoryRaw is! String || categoryRaw.trim().isEmpty) {
      throw ArgumentError('MenuItem: chiave "category" mancante o non valida');
    }

    /* ---- Conversione prezzo a double e controllo finitezza ---- */
    final priceVal = priceRaw.toDouble();
    if (priceVal.isNaN || priceVal.isInfinite) {
      throw ArgumentError('MenuItem: "price" non finito/valido');
    }

    /* ---- Normalizza descrizione opzionale (trim e empty -> null) ---- */
    String? descVal;
    final descRaw = json['description'];
    if (descRaw is String) {
      final trimmed = descRaw.trim();
      if (trimmed.isNotEmpty) descVal = trimmed;
    }

    /* ---- Ritorna l’istanza con campi normalizzati (categoria in minuscolo) ---- */
    return MenuItem(
      title: titleRaw.trim(),
      price: priceVal,
      image: imageRaw.trim(),
      description: descVal,
      category: categoryRaw.trim().toLowerCase(),
    );
  }
}
