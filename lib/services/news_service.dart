/* ---- Servizio notizie: cache-first su SharedPreferences, fallback rete su NewsAPI, riduzione campi rilevanti ---- */
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crunchy/services/app_secrets.dart';
import 'package:crunchy/services/news_cache.dart';

class NewsService {
  /* ---- Dipendenze iniettabili: client HTTP e cache ---- */
  final http.Client _client;
  final NewsCache _cache;

  /* ---- Flag usato in CI per non bloccare se manca la chiave ---- */
  static const bool _isCI = bool.fromEnvironment('CI', defaultValue: false);

  /* ---- Lettura chiave da AppSecrets ---- */
  static String get _apiKey => AppSecrets.newsKey;

  /* ---- Costruttore con injection (default: http.Client e NewsCache) ---- */
  NewsService({http.Client? client, NewsCache? cache})
      : _client = client ?? http.Client(),
        _cache = cache ?? const NewsCache();

  /* ---- Costruzione URI per NewsAPI (query italiana su cibo/ristorazione) ---- */
  static Uri _buildUri(String apiKey) => Uri.https(
        'newsapi.org',
        '/v2/everything',
        {
          'q': 'cibo OR ristorazione',
          'language': 'it',
          'apiKey': apiKey,
        },
      );

  /* ---- Fetch notizie: 1) cache-first 2) rete (con chiave) 3) salva in cache ---- */
  Future<List<Map<String, dynamic>>> fetchNews({bool allowCache = true}) async {
    /* ---- 1) Provo la cache (se consentito) ---- */
    if (allowCache) {
      final raw = await _cache.tryLoadRaw();
      if (raw.isNotEmpty) return raw;
    }

    /* ---- 2) Rete: se manca la chiave e non è CI, sollevo errore ---- */
    final key = _apiKey;
    if (key.isEmpty && !_isCI) {
      throw Exception('Chiave NewsAPI assente');
    }

    /* ---- GET con timeout breve ---- */
    final res = await _client
        .get(_buildUri(key))
        .timeout(const Duration(seconds: 8));

    if (res.statusCode != 200) {
      throw Exception('Status ${res.statusCode}');
    }

    /* ---- Parsing JSON e riduzione al set minimo di campi utili ---- */
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

    /* ---- Persiste in cache (best-effort) ---- */
    try {
      await _cache.saveRaw(reduced);
    } catch (_) {}

    return reduced;
  }
}
