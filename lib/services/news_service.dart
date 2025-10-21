import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crunchy/services/app_secrets.dart';
import 'package:crunchy/services/news_cache.dart';

class NewsService {
  final http.Client _client;
  final NewsCache _cache;

  static const bool _isCI = bool.fromEnvironment('CI', defaultValue: false);

  static String get _apiKey => AppSecrets.newsKey;

  NewsService({http.Client? client, NewsCache? cache})
      : _client = client ?? http.Client(),
        _cache = cache ?? const NewsCache();

  static Uri _buildUri(String apiKey) => Uri.https(
        'newsapi.org',
        '/v2/everything',
        {
          'q': 'cibo OR ristorazione',
          'language': 'it',
          'apiKey': apiKey,
        },
      );

  Future<List<Map<String, dynamic>>> fetchNews({bool allowCache = true}) async {
    // 1) Cache-first (usa la cache INIETTATA)
    if (allowCache) {
      final raw = await _cache.tryLoadRaw();
      if (raw.isNotEmpty) return raw;
    }

    // 2) Rete (non bloccare in CI se la chiave è vuota)
    final key = _apiKey;
    if (key.isEmpty && !_isCI) {
      throw Exception('Chiave NewsAPI assente');
    }

    final res = await _client
        .get(_buildUri(key))
        .timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) {
      throw Exception('Status ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['articles'] as List? ?? const <dynamic>[])
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .toList(growable: false);

    final reduced = list.map<Map<String, dynamic>>((a) {
      final src = (a['source'] is Map)
          ? (a['source'] as Map).cast<String, dynamic>()
          : const <String, dynamic>{};
      final urlToImage = a['urlToImage'];
      return {
        'title': a['title'],
        'url': a['url'],
        'publishedAt': a['publishedAt'],
        'urlToImage':
            (urlToImage is String && urlToImage.isNotEmpty) ? urlToImage : null,
        'source': {'name': src['name']},
      };
    }).toList(growable: false);

    // 3) Salva nella cache INIETTATA
    try {
      await _cache.saveRaw(reduced);
    } catch (_) {}

    return reduced;
  }
}
