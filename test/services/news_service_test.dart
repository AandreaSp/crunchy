import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:crunchy/services/news_service.dart';
import 'package:crunchy/services/news_cache.dart';

// Fake cache in-memory per non toccare SharedPreferences
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
      _FakeCache._store = [
        {
          'title': 'Da cache',
          'url': 'https://example.com',
          'publishedAt': '2025-10-21T10:00:00Z',
          'urlToImage': null,
          'source': {'name': 'CacheSource'}
        }
      ];

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

    test('chiama rete se cache vuota e poi salva in cache', () async {
      _FakeCache._store = [];

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

      final mockClient = MockClient((req) async {
        return http.Response(jsonEncode(payload), 200);
      });

      final svc = NewsService(client: mockClient, cache: const _FakeCache());
      final res = await svc.fetchNews(allowCache: true);

      expect(res.length, 1);
      expect(res.first['title'], 'Da rete');

      final cached = await const _FakeCache().tryLoadRaw();
      expect(cached.length, 1);
      expect(cached.first['title'], 'Da rete');
    });
  });
}
