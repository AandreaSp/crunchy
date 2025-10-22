/* ---- Repo menù: carica elementi dal JSON asset con cache in memoria ---- */
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/menu_item.dart';

class MenuRepo {
  static List<MenuItem>? _cache;
  static const _assetPath = 'asset/menu.json';

  /* ---- Ritorna la lista dei piatti: usa cache se disponibile, altrimenti legge/parsa l’asset ---- */
  static Future<List<MenuItem>> load() async {
    /* ---- Cache per evitare letture ripetute dal bundle ---- */
    if (_cache != null) return List.unmodifiable(_cache!);

    /* ---- Lettura asset e parsing JSON -> mapping in modelli forti ---- */
    final raw = await rootBundle.loadString(_assetPath);
    final list = (jsonDecode(raw) as List).cast<Map<String, dynamic>>();
    _cache = list.map(MenuItem.fromJson).toList(growable: false);

    /* ---- Ritorna una vista non modificabile ---- */
    return List.unmodifiable(_cache!);
  }
}
