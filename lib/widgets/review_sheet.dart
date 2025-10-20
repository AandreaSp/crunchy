import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';

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
  final _text = TextEditingController();
  final _picker = ImagePicker();
  final List<XFile> _photos = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    // Rende reattivo il bottone "Conferma" quando cambia il testo
    _text.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _takePhoto() async {
    try {
      final pic = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1600,
      );
      if (pic != null) setState(() => _photos.add(pic));
    } on PlatformException catch (_) {}
  }

  Future<void> _pickFromGallery() async {
    try {
      final pics = await _picker.pickMultiImage(maxWidth: 1600);
      if (pics.isNotEmpty) setState(() => _photos.addAll(pics));
    } on PlatformException catch (_) {}
  }

  void _removePhotoAt(int index) {
    setState(() => _photos.removeAt(index));
  }

  Future<void> _confirm() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(true);
  }

  bool get _canConfirm =>
      !_sending && (_text.text.trim().isNotEmpty || _photos.isNotEmpty);

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 16 + insets),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
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

          // Testo + azioni foto
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

          // Galleria selezionata (orizzontale, con X per rimuovere)
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
