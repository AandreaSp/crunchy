import 'package:shared_preferences/shared_preferences.dart';

class LocalPrefs {
  LocalPrefs._();
  static final LocalPrefs I = LocalPrefs._();

  // Chiavi - v1 per future migrazioni
  static const String kLastTabIndex    = 'last_tab_index_v1';
  static const String kLastSearchQuery = 'last_search_query_v1';
  static const String kLastLat         = 'last_lat_v1';
  static const String kLastLng         = 'last_lng_v1';
  static const String kSearchHistory   = 'search_history_v1';
  static const String kNewsCacheJson   = 'news_cache_json_v1';
  static const String kNewsCacheTs     = 'news_cache_ts_v1';

  Future<SharedPreferences> get _p async => SharedPreferences.getInstance();

  // String
  Future<String?> getString(String key) async => (await _p).getString(key);
  Future<void> setString(String key, String? value) async {
    final p = await _p;
    if (value == null) {
      await p.remove(key);
    } else {
      await p.setString(key, value);
    }
  }

  // Int
  Future<int?> getInt(String key) async => (await _p).getInt(key);
  Future<void> setInt(String key, int? value) async {
    final p = await _p;
    if (value == null) {
      await p.remove(key);
    } else {
      await p.setInt(key, value);
    }
  }

  // Double
  Future<double?> getDouble(String key) async => (await _p).getDouble(key);
  Future<void> setDouble(String key, double? value) async {
    final p = await _p;
    if (value == null) {
      await p.remove(key);
    } else {
      await p.setDouble(key, value);
    }
  }

  // Liste
  Future<List<String>> getStringList(String key) async =>
      (await _p).getStringList(key) ?? <String>[];

  Future<void> setStringList(String key, List<String>? value) async {
    final p = await _p;
    if (value == null) {
      await p.remove(key);
    } else {
      await p.setStringList(key, value);
    }
  }
}
