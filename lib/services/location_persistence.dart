import 'package:crunchy/services/local_prefs.dart';

class LocationPersistence {
  const LocationPersistence();

  Future<String> loadLastQuery() async =>
      await LocalPrefs.I.getString(LocalPrefs.kLastSearchQuery) ?? '';

  Future<void> saveLastQuery(String query) async =>
      LocalPrefs.I.setString(LocalPrefs.kLastSearchQuery, query);

  Future<List<String>> loadHistory() async =>
      await LocalPrefs.I.getStringList(LocalPrefs.kSearchHistory);

  Future<List<String>> pushHistory(String query) async {
    final current = await loadHistory();
    final next = <String>[query, ...current.where((e) => e != query)];
    if (next.length > 5) next.removeRange(5, next.length);
    await LocalPrefs.I.setStringList(LocalPrefs.kSearchHistory, next);
    return next;
  }

  Future<(double? lat, double? lng)> loadLastLatLng() async {
    final lat = await LocalPrefs.I.getDouble(LocalPrefs.kLastLat);
    final lng = await LocalPrefs.I.getDouble(LocalPrefs.kLastLng);
    return (lat, lng);
  }

  Future<void> saveLastLatLng(double lat, double lng) async {
    await LocalPrefs.I.setDouble(LocalPrefs.kLastLat, lat);
    await LocalPrefs.I.setDouble(LocalPrefs.kLastLng, lng);
  }
}
