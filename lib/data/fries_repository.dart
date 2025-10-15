import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/fries_item.dart';

class FriesRepo {
  static List<FriesItem>? _cache;
  static const _assetPath = 'asset/fritti.json';

  // Carica i fritti dal file JSON con cache in memoria.
  static Future<List<FriesItem>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _cache = list.map(FriesItem.fromJson).toList();
    return _cache!;
  }
}
