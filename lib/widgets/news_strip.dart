import 'package:flutter/material.dart';
import 'package:crunchy/services/news_service.dart';
import 'package:url_launcher/url_launcher.dart';

typedef RefreshCallback = Future<void> Function();

class NewsStrip extends StatefulWidget {
  final RefreshCallback onRefresh;
  const NewsStrip({super.key, required this.onRefresh});

  @override
  State<NewsStrip> createState() => _NewsStripState();
}

class _NewsStripState extends State<NewsStrip> {
  final _service = NewsService();
  bool _loading = true;
  String _error = '';
  List<Map<String, dynamic>> _items = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = '';
    });
    try {
      _items = await _service.fetchNews();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 22, 16, 10),
          child: Text(
            'Ultime notizie',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ),
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (_error.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Errore notizie: $_error',
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                IconButton(
                  onPressed: _load,
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) {
                final a = _items[i];
                final img = a['urlToImage'] as String?;
                final source = (a['source']?['name'] ?? '') as String;
                final published =
                    (a['publishedAt'] as String?)?.substring(0, 10).replaceAll('-', ' ');
                final label =
                    (published != null && published.isNotEmpty) ? '$source • $published' : source;

                return Container(
                  width: 300,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () async {
                        final raw = a['url'] as String?;
                        final uri = raw != null ? Uri.tryParse(raw) : null;
                        if (uri != null && await canLaunchUrl(uri)) {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (img != null && img.isNotEmpty)
                            Image.network(
                              img,
                              fit: BoxFit.cover,
                              loadingBuilder: (ctx, child, evt) {
                                if (evt == null) return child;
                                return Container(color: cs.surfaceContainerHighest);
                              },
                              errorBuilder: (_, __, ___) =>
                                  Container(color: cs.surfaceContainerHighest),
                            )
                          else
                            Container(color: cs.surfaceContainerHighest),
                          Container(color: Colors.black26),
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white70,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 16,
                            left: 12,
                            right: 12,
                            child: Text(
                              (a['title'] ?? '') as String,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        const SizedBox(height: 100),
      ],
    );
  }
}
