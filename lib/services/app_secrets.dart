/* ---- Chiavi API dell’app ---- */
class AppSecrets {
  /* ---- NEWS_API_KEY per servizio notizie; MAPS_API_KEY per Google Places/Maps ---- */
  static const String newsKey = String.fromEnvironment('NEWS_API_KEY', defaultValue: '');
  static const String placesKey = String.fromEnvironment('MAPS_API_KEY', defaultValue: '');
}
