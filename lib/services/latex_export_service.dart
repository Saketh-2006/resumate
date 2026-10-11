import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';

class LatexExportService {
  static Future<void> saveSource(String source, String resumeName) async {
    final baseName = resumeName
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9_-]+'), '_')
        .replaceAll(RegExp(r'^_+|_+$'), '');
    await FilePicker.saveFile(
      fileName: '${baseName.isEmpty ? 'Resume' : baseName}_Resume.tex',
      bytes: Uint8List.fromList(utf8.encode(source)),
      mimeType: 'application/x-tex',
      dialogTitle: 'Save your LaTeX resume source',
      type: FileType.custom,
      allowedExtensions: const ['tex'],
    );
  }
}
