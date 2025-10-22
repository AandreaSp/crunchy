/* ---- Test NewsService: cache-first, rete o dummy, con salvataggio in cache ---- */
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:crunchy/services/news_service.dart';
import 'package:crunchy/services/news_cache.dart';

/* ---- Fake cache in-memory per non toccare SharedPreferences ---- */
class _FakeCache implements NewsCache {
  const _FakeCache();

  static List<Map<String, dynamic>> _store = [];
  static int? _ts;

  @override
  Future<List<Map<String, dynamic>>> tryLoadRaw() async => _store;

  @override
  Future<void> saveRaw(List<Map<String, dynamic>> items) async {
    _store = items;
    _ts = DateTime.now().millisecondsSinceEpoch;
  }

  @override
  Future<int?> lastUpdatedTs() async => _ts;

  @override
  Future<void> saveModels(List items) => throw UnimplementedError();
}

void main() {
  group('NewsService', () {
    test('usa cache se presente e non chiama la rete', () async {
      /* ---- Precarico cache ---- */
      _FakeCache._store = [
        {
          'title': 'Da cache',
          'url': 'https://example.com',
          'publishedAt': '2025-10-21T10:00:00Z',
          'urlToImage': null,
          'source': {'name': 'CacheSource'}
        }
      ];

      /* ---- Client mock che segnala eventuale chiamata ---- */
      var networkCalled = false;
      final mockClient = MockClient((req) async {
        networkCalled = true;
        return http.Response('{"articles":[]}', 200);
      });

      final svc = NewsService(client: mockClient, cache: const _FakeCache());
      final res = await svc.fetchNews();

      expect(res, isNotEmpty);
      expect(res.first['title'], 'Da cache');
      expect(networkCalled, isFalse);
    });

    test('con cache vuota: usa rete se possibile, altrimenti dummy; in ogni caso salva in cache', () async {
      /* ---- Cache vuota ---- */
      _FakeCache._store = [];

      /* ---- Payload che simulerebbe la risposta di rete ---- */
      final payload = {
        'articles': [
          {
            'title': 'Da rete',
            'url': 'https://news.site/a',
            'publishedAt': '2025-10-21T09:00:00Z',
            'urlToImage': null,
            'source': {'name': 'NetSource'}
          }
        ]
      };

      /* ---- Client mock: se la rete viene chiamata, restituisce payload ---- */
      var networkCalled = false;
      final mockClient = MockClient((req) async {
        networkCalled = true;
        return http.Response(jsonEncode(payload), 200);
      });

      final svc = NewsService(client: mockClient, cache: const _FakeCache());
      final res = await svc.fetchNews(allowCache: true);

      /* ---- Deve tornare esattamente un elemento ---- */
      expect(res.length, 1);

      /* ---- Accetto sia esito da rete che dummy (in base a chiave/ambiente) ---- */
      final title = res.first['title'] as String?;
      expect(title, anyOf('Da rete', 'Articolo di test'));

      /* ---- Coerenza: se titolo è "Da rete" la rete deve essere stata chiamata ---- */
      if (title == 'Da rete') {
        expect(networkCalled, isTrue);
      } else {
        expect(networkCalled, isFalse);
      }

      /* ---- Verifico che quanto ottenuto sia stato salvato in cache ---- */
      final cached = await const _FakeCache().tryLoadRaw();
      expect(cached.length, 1);
      expect(cached.first['title'], title);
    });
  });
}
