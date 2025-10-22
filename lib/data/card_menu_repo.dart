/* ---- Repo categorie menù: carica dal JSON asset con cache in memoria ---- */
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/card_menu_category.dart';

class MenuCategoriesRepo {
  static const _assetPath = 'asset/menu_card.json';
  static List<MenuCategory>? _cache;

  /* ---- Ritorna la lista di categorie: usa cache se presente, altrimenti legge/parsa l'asset ---- */
  static Future<List<MenuCategory>> load() async {
    /* ---- Cache in RAM per evitare letture ripetute ---- */
    if (_cache != null) return List.unmodifiable(_cache!);

    /* ---- Lettura asset e parsing JSON ---- */
    final raw = await rootBundle.loadString(_assetPath);
    final root = jsonDecode(raw) as Map<String, dynamic>;
    final list = (root['categories'] as List).cast<Map<String, dynamic>>();

    /* ---- Mapping in modelli forti e memorizzazione ---- */
    _cache = list.map(MenuCategory.fromJson).toList(growable: false);
    return List.unmodifiable(_cache!);
  }
}
