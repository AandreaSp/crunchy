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

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final titleRaw = json['title'];
    final priceRaw = json['price'];
    final imageRaw = json['image'];
    final categoryRaw = json['category'];

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

    final priceVal = priceRaw.toDouble();
    if (priceVal.isNaN || priceVal.isInfinite) {
      throw ArgumentError('MenuItem: "price" non finito/valido');
    }

    String? descVal;
    final descRaw = json['description'];
    if (descRaw is String) {
      final trimmed = descRaw.trim();
      if (trimmed.isNotEmpty) descVal = trimmed;
    }

    return MenuItem(
      title: titleRaw.trim(),
      price: priceVal,
      image: imageRaw.trim(),
      description: descVal,
      category: categoryRaw.trim().toLowerCase(),
    );
  }
}
