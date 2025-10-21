class AppSecrets {
  static const String newsKey = String.fromEnvironment('NEWS_API_KEY', defaultValue: '');
  static const String placesKey =String.fromEnvironment('PLACES_API_KEY', defaultValue: '');
}
