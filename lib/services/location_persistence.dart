/* ---- Persistenza semplice per ricerca/cronologia e ultima posizione (lat/lng) ---- */
import 'package:crunchy/services/local_prefs.dart';

class LocationPersistence {
  const LocationPersistence();

  /* ---- Ultima query cercata (stringa vuota se assente) ---- */
  Future<String> loadLastQuery() async =>
      await LocalPrefs.I.getString(LocalPrefs.kLastSearchQuery) ?? '';

  /* ---- Salva l’ultima query ---- */
  Future<void> saveLastQuery(String query) async =>
      LocalPrefs.I.setString(LocalPrefs.kLastSearchQuery, query);

  /* ---- Cronologia ricerche (lista, può essere vuota) ---- */
  Future<List<String>> loadHistory() async =>
      await LocalPrefs.I.getStringList(LocalPrefs.kSearchHistory);

  /* ---- Aggiunge query in testa alla cronologia, senza duplicati e max 5 elementi ---- */
  Future<List<String>> pushHistory(String query) async {
    final current = await loadHistory();
    final next = <String>[query, ...current.where((e) => e != query)];
    if (next.length > 5) next.removeRange(5, next.length);
    await LocalPrefs.I.setStringList(LocalPrefs.kSearchHistory, next);
    return next;
  }

  /* ---- Carica ultima lat/lng salvata (null se non presente) ---- */
  Future<(double? lat, double? lng)> loadLastLatLng() async {
    final lat = await LocalPrefs.I.getDouble(LocalPrefs.kLastLat);
    final lng = await LocalPrefs.I.getDouble(LocalPrefs.kLastLng);
    return (lat, lng);
  }

  /* ---- Salva ultima lat/lng ---- */
  Future<void> saveLastLatLng(double lat, double lng) async {
    await LocalPrefs.I.setDouble(LocalPrefs.kLastLat, lat);
    await LocalPrefs.I.setDouble(LocalPrefs.kLastLng, lng);
  }
}
