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

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        image: json['image'] as String,
        description: (json['description'] ?? json['unit']) as String?,
        category: json['category'] as String,
      );
}
