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
  XFile? _photo;
  bool _sending = false;

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
      if (pic != null) setState(() => _photo = pic);
    } on PlatformException catch (_) {}
  }

  Future<void> _confirm() async {
    setState(() => _sending = true);
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;
    HapticFeedback.lightImpact();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final insets = MediaQuery.of(context).viewInsets.bottom;

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
                child: FloatingActionButton.small(
                  heroTag: 'camera_sheet',
                  onPressed: _takePhoto,
                  child: const Icon(Icons.photo_camera),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (_photo != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                File(_photo!.path),
                height: 160,
                fit: BoxFit.cover,
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
                  onPressed: _sending || _text.text.trim().isEmpty
                      ? null
                      : _confirm,
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
