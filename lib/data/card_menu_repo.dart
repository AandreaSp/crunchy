import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card_menu_category.dart';

class MenuCategoriesRepo {
  static const _assetPath = 'asset/menu_card.json';
  static List<MenuCategory>? _cache;

  static Future<List<MenuCategory>> load() async {
  if (_cache != null) return List.unmodifiable(_cache!);
  final raw = await rootBundle.loadString(_assetPath);
  final root = jsonDecode(raw) as Map<String, dynamic>;
  final list = (root['categories'] as List).cast<Map<String, dynamic>>();
  _cache = list.map(MenuCategory.fromJson).toList(growable: false);
  return List.unmodifiable(_cache!);
  }
}
