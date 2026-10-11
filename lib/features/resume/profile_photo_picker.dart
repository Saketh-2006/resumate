import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Optional, per-resume profile photo stored in the app's private documents dir.
class ProfilePhotoPicker extends StatefulWidget {
  const ProfilePhotoPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<ProfilePhotoPicker> createState() => _ProfilePhotoPickerState();
}

class _ProfilePhotoPickerState extends State<ProfilePhotoPicker> {
  bool _busy = false;

  Future<void> _pick() async {
    setState(() => _busy = true);
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 88,
      );
      if (image == null || !mounted) return;
      final directory = await getApplicationDocumentsDirectory();
      final photos = Directory('${directory.path}/profile_photos');
      await photos.create(recursive: true);
      final ext = image.name.contains('.') ? image.name.split('.').last : 'jpg';
      final destination = File(
        '${photos.path}/${DateTime.now().microsecondsSinceEpoch}.$ext',
      );
      await File(image.path).copy(destination.path);
      if (mounted) widget.onChanged(destination.path);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not open or save that photo. Check gallery access and try again.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = widget.value.isNotEmpty && File(widget.value).existsSync();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest,
              backgroundImage: hasPhoto ? FileImage(File(widget.value)) : null,
              child: hasPhoto
                  ? null
                  : const Icon(Icons.person_outline, size: 34),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Profile photo (optional)',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  Text(
                    hasPhoto
                        ? 'Shown on supported resume templates'
                        : 'Add a photo to your resume',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (_busy)
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              IconButton(
                onPressed: _pick,
                tooltip: hasPhoto ? 'Change photo' : 'Choose photo',
                icon: const Icon(Icons.photo_library_outlined),
              ),
            if (hasPhoto)
              IconButton(
                onPressed: () => widget.onChanged(''),
                tooltip: 'Remove photo',
                icon: const Icon(Icons.delete_outline),
              ),
          ],
        ),
      ),
    );
  }
}
