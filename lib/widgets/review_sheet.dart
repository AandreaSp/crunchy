/* ---- Bottom sheet per inserire una recensione con testo e foto (camera/galleria), con conferma e annulla ---- */
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

/* ---- Mostra il foglio modale e restituisce true/false a seconda della conferma ---- */
Future<bool?> openReviewSheet(BuildContext context) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => const _ReviewSheet(),
  );
}

class _ReviewSheet extends StatefulWidget {
  const _ReviewSheet();
  @override
  State<_ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<_ReviewSheet> {
  /* ---- Controller testo, picker immagini e stato locale (foto selezionate / invio in corso) ---- */
  final _text = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  /* ---- Scatta una foto dalla fotocamera e aggiunge alla lista ---- */
  Future<void> _takePhoto() async {
    try {
      final pic = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
      );
      if (pic != null) setState(() => _photos.add(pic));
    } on PlatformException catch (_) {}
  }

  /* ---- Seleziona più foto dalla galleria e le aggiunge alla lista ---- */
  Future<void> _pickFromGallery() async {
    try {
      final pics = await _picker.pickMultiImage(maxWidth: 1600);
      if (pics.isNotEmpty) setState(() => _photos.addAll(pics));
    } on PlatformException catch (_) {}
  }

  /* ---- Rimuove una foto dall’anteprima ---- */
  void _removePhotoAt(int index) {
    setState(() => _photos.removeAt(index));
  }

  /* ---- Conferma: finto invio, feedback aptico e chiusura con risultato true ---- */
  Future<void> _confirm() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(true);
  }

  /* ---- Abilita il pulsante di conferma solo se c’è testo o almeno una foto e non sto inviando ---- */
  bool get _canConfirm =>
      !_sending && (_text.text.trim().isNotEmpty || _photos.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final cs = Theme.of(context).colorScheme;

    /* ---- Contenuto del foglio: titolo, input testo con azioni foto, anteprime e pulsanti ---- */
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /* ---- Intestazione con titolo e chiusura ---- */
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Lascia una recensione',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context, false),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 8),

          /* ---- Campo testo con menu rapido per aggiungere foto (camera/galleria) ---- */
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              TextField(
                controller: _text,
                maxLines: 4,
                maxLength: 280,
                decoration: InputDecoration(
                  hintText: 'Scrivi una recensione...',
                  counterText: '',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(12, 12, 56, 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8),
                child: PopupMenuButton<String>(
                  tooltip: 'Aggiungi foto',
                  icon: const Icon(Icons.add_a_photo),
                  onSelected: (v) {
                    if (v == 'camera') _takePhoto();
                    if (v == 'gallery') _pickFromGallery();
                  },
                  itemBuilder: (ctx) => const [
                    PopupMenuItem(
                      value: 'camera',
                      child: ListTile(
                        leading: Icon(Icons.photo_camera),
                        title: Text('Scatta foto'),
                      ),
                    ),
                    PopupMenuItem(
                      value: 'gallery',
                      child: ListTile(
                        leading: Icon(Icons.photo_library),
                        title: Text('Seleziona dalla galleria'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          /* ---- Lista orizzontale delle foto selezionate con tasto di rimozione ---- */
          if (_photos.isNotEmpty)
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, i) {
                  final file = File(_photos[i].path);
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          file,
                          width: 150,
                          height: 110,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        top: 4,
                        child: InkWell(
                          onTap: () => _removePhotoAt(i),
                          child: Container(
                            decoration: BoxDecoration(
                              color: cs.surface.withValues(alpha: 0.85),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(Icons.close, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

          const SizedBox(height: 14),

          /* ---- Pulsanti di azione: annulla e conferma (con loader durante l’invio) ---- */
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: ButtonStyle(
                    backgroundColor: const WidgetStatePropertyAll(Colors.white),
                    foregroundColor: WidgetStatePropertyAll(
                      Theme.of(context).colorScheme.onSurface,
                    ),
                    overlayColor: WidgetStatePropertyAll(
                      Colors.black.withValues(alpha: 0.05),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Annulla'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: _canConfirm ? _confirm : null,
                  child: _sending
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Conferma'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
