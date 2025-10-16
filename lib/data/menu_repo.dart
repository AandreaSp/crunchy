import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/menu_item.dart';

class MenuRepo {
  static List<MenuItem>? _cache;
  static const _assetPath = 'asset/menu.json';

  static Future<List<MenuItem>> load() async {
    if (_cache != null) return List.unmodifiable(_cache!);
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _cache = list.map(MenuItem.fromJson).toList(growable: false);
    return List.unmodifiable(_cache!);
  }
}
