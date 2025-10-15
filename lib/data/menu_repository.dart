import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/menu_category.dart';

class MenuCategoriesRepo {
  static const _assetPath = 'asset/menu.json';
  static List<MenuCategory>? _cache;

  // Carica il menu dal file JSON con cache in memoria.
  static Future<List<MenuCategory>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final list = (root['categories'] as List).cast<Map<String, dynamic>>();
    _cache = list.map(MenuCategory.fromJson).toList();
    return _cache!;
  }
}
