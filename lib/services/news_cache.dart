import 'dart:convert';
import 'package:crunchy/services/local_prefs.dart';

abstract class CacheJson {
  Map<String, dynamic> toCacheJson();
}

class NewsCache {
  const NewsCache();

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

  Future<int?> lastUpdatedTs() => LocalPrefs.I.getInt(LocalPrefs.kNewsCacheTs);

  Future<void> saveModels(List<CacheJson> items) =>
      saveRaw(items.map((e) => e.toCacheJson()).toList());
}
