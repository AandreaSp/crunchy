class MenuCategory {
  final String title;
  final String imageAsset;

  const MenuCategory({
    required this.title,
    required this.imageAsset,
  });

  factory MenuCategory.fromJson(Map<String, dynamic> json) => MenuCategory(
        title: json['title'] as String,
        imageAsset: json['imageAsset'] as String,
      );
}
