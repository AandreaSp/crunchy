class FriesItem {
  final String title;
  final double price;
  final String unit;
  final String image;

  const FriesItem({
    required this.title,
    required this.price,
    required this.unit,
    required this.image,
  });

  factory FriesItem.fromJson(Map<String, dynamic> json) => FriesItem(
        title: json['title'] as String,
        price: (json['price'] as num).toDouble(),
        unit: json['unit'] as String,
        image: json['image'] as String,
      );
}
