import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crunchy/generated/secrets.g.dart';
import 'package:crunchy/services/news_cache.dart';

class NewsService {
  static const _apiKey = AppSecrets.newsKey;
  static const _endpoint =
      'https://newsapi.org/v2/everything'
      '?q=cibo%20OR%20ristorazione'
      '&language=it'
      '&apiKey=$_apiKey';

  // Iniezione per i test
  final http.Client _client;
  final NewsCache _cache;

  NewsService({http.Client? client, NewsCache? cache})
      : _client = client ?? http.Client(),
        _cache = cache ?? const NewsCache();

  Future<List<Map<String, dynamic>>> fetchNews({bool allowCache = true}) async {
    // 1) Cache-first
    if (allowCache) {
      final raw = await _cache.tryLoadRaw();
      if (raw.isNotEmpty) return raw;
    }

    // 2) Rete
    if (_apiKey.isEmpty) {
      throw Exception('Chiave NewsAPI assente');
    }

    final uri = Uri.parse(_endpoint);
    final res = await _client.get(uri).timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) {
      throw Exception('Status ${res.statusCode}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final list = (data['articles'] as List? ?? const <dynamic>[])
        .whereType<Map>()
        .map((m) => m.cast<String, dynamic>())
        .toList(growable: false);

    final reduced = list.map<Map<String, dynamic>>((a) {
      final src = (a['source'] is Map) ? (a['source'] as Map).cast<String, dynamic>() : const <String, dynamic>{};
      final urlToImage = a['urlToImage'];
      return {
        'title': a['title'],
        'url': a['url'],
        'publishedAt': a['publishedAt'],
        'urlToImage': (urlToImage is String && urlToImage.isNotEmpty) ? urlToImage : null,
        'source': {'name': src['name']},
      };
    }).toList(growable: false);

    // 3) Aggiorna cache (best-effort)
    try {
      await _cache.saveRaw(reduced);
    } catch (_) {
      // ignora errori di cache
    }

    return reduced;
  }
}
