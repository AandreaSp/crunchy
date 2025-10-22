/* ---- Strip "Ultime notizie" con gestione robusta di offline/errore ---- */
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:crunchy/services/news_service.dart';

/* ---- Callback per refresh esterni ---- */
typedef RefreshCallback = Future<void> Function();

/* ---- Widget per la sezione notizie ---- */
class NewsStrip extends StatefulWidget {
  final RefreshCallback? onRefresh; 
  const NewsStrip({super.key, this.onRefresh});

  @override
  State<NewsStrip> createState() => _NewsStripState();
}

/* ---- Stato interno: caricamento, errore, lista articoli ---- */
class _NewsStripState extends State<NewsStrip> {
  /* ---- Service + stato locale ---- */
  final _service = NewsService();
  bool _loading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _items = const [];

  /* ---- Avvio: forza rete per evitare cache quando offline ---- */
  @override
  void initState() {
    super.initState();
    _load(forceNetwork: true);
  }

  /* ---- Caricamento notizie ---- */
  Future<void> _load({bool forceNetwork = true}) async {
    setState(() {
      _loading = true;
      _hasError = false;
    });

    try {
      final items = await _service.fetchNews(allowCache: !forceNetwork);
      if (!mounted) return;

      setState(() {
        _items = items;
        _hasError = items.isEmpty; 
        _loading = false;
      });

      if (items.isNotEmpty && widget.onRefresh != null) {
        await widget.onRefresh!.call();
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;   
        _loading = false;
        _items = const [];
      });
    }
  }

  /* ---- Card di stato "nessuna notizia" con tasto refresh ---- */
  Widget _emptyState(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      height: 110,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(Icons.event_note, size: 28, color: cs.onSurfaceVariant),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Nessuna notizia disponibile al momento.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          IconButton(
            tooltip: 'Aggiorna',
            onPressed: () => _load(forceNetwork: true),
            icon: Icon(Icons.refresh, color: cs.onSurfaceVariant),
          ),
        ],
      ),
    );
  }

  /* ---- Card singola di notizia ---- */
  Widget _newsCard(BuildContext context, Map<String, dynamic> a) {
    final cs = Theme.of(context).colorScheme;
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
      ),
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
            /* ---- Immagine con fallback ---- */
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

            /* ---- Overlay scuro per contrasto del testo ---- */
            Container(color: Colors.black26),

            /* ---- Badge sorgente/data ---- */
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Align(
                alignment: Alignment.topLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),

            /* ---- Titolo della notizia ---- */
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
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /* ---- Build: titolo, loading, stato vuoto/errore, lista orizzontale ---- */
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        /* ---- Intestazione sezione ---- */
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
          child: Text(
            "Vuoi ingannare l'attesa?",
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),

        /* ---- Stato: caricamento ---- */
        if (_loading)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          )

        /* ---- Stato: errore o nessun contenuto ---- */
        else if (_hasError)
          _emptyState(context)

        /* ---- Stato: contenuti disponibili ---- */
        else
          SizedBox(
            height: 210,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, i) => _newsCard(context, _items[i]),
            ),
          ),

        /* ---- Spaziatura finale ---- */
        const SizedBox(height: 10),
      ],
    );
  }
}
