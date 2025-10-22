/* ---- Cache news su SharedPreferences: salva/legge JSON grezzo + timestamp ---- */
import 'dart:convert';
import 'package:crunchy/services/local_prefs.dart';

/* ---- Contratto per modelli che possono essere serializzati in cache come Map<String, dynamic> ---- */
abstract class CacheJson {
  Map<String, dynamic> toCacheJson();
}

class NewsCache {
  const NewsCache();

  /* ---- Prova a leggere la lista grezza dal cache (JSON) -> [] se non presente o parsing fallito ---- */
  Future<List<Map<String, dynamic>>> tryLoadRaw() async {
    final jsonStr = await LocalPrefs.I.getString(LocalPrefs.kNewsCacheJson);
    if (jsonStr == null || jsonStr.isEmpty) return [];
    try {
      final List data = json.decode(jsonStr) as List;
      return data.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  /* ---- Salva lista grezza in JSON e registra anche il timestamp dell’ultimo aggiornamento ---- */
  Future<void> saveRaw(List<Map<String, dynamic>> items) async {
    try {
      await LocalPrefs.I.setString(
        LocalPrefs.kNewsCacheJson,
        json.encode(items),
      );
      await LocalPrefs.I.setInt(
        LocalPrefs.kNewsCacheTs,
        DateTime.now().millisecondsSinceEpoch,
      );
    } catch (_) {
      // ignore
    }
  }

  /* ---- Ritorna il timestamp (ms) dell’ultimo salvataggio, se presente ---- */
  Future<int?> lastUpdatedTs() => LocalPrefs.I.getInt(LocalPrefs.kNewsCacheTs);

  /* ---- Salva una lista di modelli che implementano CacheJson, convertendoli a Map prima del salvataggio ---- */
  Future<void> saveModels(List<CacheJson> items) =>
      saveRaw(items.map((e) => e.toCacheJson()).toList());
}
