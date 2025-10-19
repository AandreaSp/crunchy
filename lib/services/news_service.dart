import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crunchy/generated/secrets.g.dart';

class NewsService {
  static const _apiKey = AppSecrets.newsKey;
  static const _endpoint =
      'https://newsapi.org/v2/everything'
      '?q=cibo%20OR%20ristorazione'
      '&language=it'
      '&apiKey=$_apiKey';

  Future<List<Map<String, dynamic>>> fetchNews() async {
    try {
      final res = await http.get(Uri.parse(_endpoint));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        return (data['articles'] as List).cast<Map<String, dynamic>>();
      }
      throw Exception('Status ${res.statusCode}');
    } catch (e) {
      rethrow;
    }
  }
}
