import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'resume_data.dart';
import 'services/draft_storage.dart';
import 'template_screen.dart';

class PhotoScreen extends StatefulWidget {
  final ResumeData resumeData;

  const PhotoScreen({super.key, required this.resumeData});

  @override
  State<PhotoScreen> createState() => _PhotoScreenState();
}

class _PhotoScreenState extends State<PhotoScreen> {
  bool _loading = false;

  Future<void> _pickPhoto() async {
    setState(() => _loading = true);
    try {
      final files = await FilePicker.pickFiles(type: FileType.image);
      if (files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw const FormatException('The image is empty.');
      if (bytes.lengthInBytes > 2 * 1024 * 1024) {
        throw const FormatException(
          'Choose an image smaller than 2 MB so it can be saved with your draft.',
        );
      }
      if (!mounted) return;
      setState(() {
        widget.resumeData.profilePhotoData = base64Encode(bytes);
        widget.resumeData.profilePhotoPath = file.name;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load the image: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _continue() async {
    try {
      await DraftStorage().save(widget.resumeData);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save your photo with the draft: $error')),
      );
      return;
    }
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TemplateScreen(resumeData: widget.resumeData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.resumeData.profilePhotoData;
    return Scaffold(
      appBar: AppBar(title: const Text('Profile photo')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 92,
                  backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                  backgroundImage:
                      data.isEmpty ? null : MemoryImage(base64Decode(data)),
                  child: data.isEmpty
                      ? Icon(
                          Icons.person_outline,
                          size: 56,
                          color: Theme.of(context).colorScheme.primary,
                        )
                      : null,
                ),
                const SizedBox(height: 20),
                Text(
                  data.isEmpty ? 'Add a professional photo' : widget.resumeData.profilePhotoPath,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                const Text(
                  'A photo is optional. Some resume styles may omit it for a cleaner ATS layout.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _pickPhoto,
                  icon: _loading
                      ? const SizedBox.square(
                          dimension: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_a_photo_outlined),
                  label: Text(data.isEmpty ? 'Choose photo' : 'Replace photo'),
                ),
                if (data.isNotEmpty)
                  TextButton(
                    onPressed: () => setState(() {
                      widget.resumeData.profilePhotoData = '';
                      widget.resumeData.profilePhotoPath = '';
                    }),
                    child: const Text('Remove photo'),
                  ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _continue,
                    child: const Text('Continue to templates'),
                  ),
                ),
                TextButton(onPressed: _continue, child: const Text('Skip')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
