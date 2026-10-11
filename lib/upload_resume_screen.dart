import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'api_service.dart';

class UploadResumeScreen extends StatefulWidget {
  const UploadResumeScreen({super.key});

  @override
  State<UploadResumeScreen> createState() => _UploadResumeScreenState();
}

class _UploadResumeScreenState extends State<UploadResumeScreen> {
  bool _loading = false;
  String? _fileName;

  Future<void> _selectResume() async {
    setState(() => _loading = true);
    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
      if (files.isEmpty) return;
      final file = files.first;
      final bytes = await file.readAsBytes();
      if (bytes.isEmpty) throw const FormatException('The selected file is empty.');
      final document = PdfDocument(inputBytes: bytes);
      late final String text;
      try {
        text = PdfTextExtractor(document).extractText();
      } finally {
        document.dispose();
      }
      if (text.trim().isEmpty) {
        throw const FormatException(
          'No selectable text was found. Scanned PDFs need OCR before analysis.',
        );
      }
      if (!mounted) return;
      setState(() => _fileName = file.name);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ResumeAnalysisScreen(
            fileName: file.name,
            extractedText: text,
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not read that PDF: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Improve an existing resume')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_outlined,
                      size: 64, color: Theme.of(context).colorScheme.primary),
                  const SizedBox(height: 16),
                  Text('Upload a PDF resume',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 8),
                  const Text(
                    'The PDF is read on this device. Only the extracted text is sent to Groq for wording suggestions, when you are online.',
                    textAlign: TextAlign.center,
                  ),
                  if (_fileName != null) ...[
                    const SizedBox(height: 16),
                    Chip(label: Text(_fileName!)),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: _loading ? null : _selectResume,
                      icon: _loading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.upload_file),
                      label: Text(_loading ? 'Reading PDF…' : 'Choose PDF'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}

class ResumeAnalysisScreen extends StatefulWidget {
  final String fileName;
  final String extractedText;

  const ResumeAnalysisScreen({
    super.key,
    required this.fileName,
    required this.extractedText,
  });

  @override
  State<ResumeAnalysisScreen> createState() => _ResumeAnalysisScreenState();
}

class _ResumeAnalysisScreenState extends State<ResumeAnalysisScreen> {
  Map<String, dynamic>? _analysis;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _analyze();
  }

  Future<void> _analyze() async {
    setState(() => _loading = true);
    final result = await ApiService.analyzeResume(widget.extractedText);
    if (!mounted) return;
    setState(() {
      _analysis = result;
      _loading = false;
    });
  }

  Future<void> _reviewChanges() async {
    final changes = (_analysis?['changes'] as List?) ?? const [];
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewSuggestedChangesScreen(
          fileName: widget.fileName,
          originalText: widget.extractedText,
          changes: changes
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final result = _analysis;
    final suggestions = (result?['suggestions'] as List?) ?? const [];
    final categories = (result?['categories'] as List?) ?? const [];
    final changes = (result?['changes'] as List?) ?? const [];
    return Scaffold(
      appBar: AppBar(title: const Text('Resume analysis')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(widget.fileName, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 16),
                if (_loading) const LinearProgressIndicator(),
                if (result != null) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 32,
                            child: Text('${result['score'] ?? 0}'),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Content coverage indicator',
                                    style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text('${result['disclaimer'] ?? ''}'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Card(
                    child: Column(
                      children: [
                        for (final item in categories.whereType<Map>())
                          ListTile(
                            dense: true,
                            leading: Icon(
                              item['status'] == 'present'
                                  ? Icons.check_circle_outline
                                  : Icons.info_outline,
                              color: item['status'] == 'present'
                                  ? Colors.green
                                  : Theme.of(context).colorScheme.tertiary,
                            ),
                            title: Text('${item['name']}'),
                            trailing: Text(item['status'] == 'present' ? 'Present' : 'Check'),
                          ),
                      ],
                    ),
                  ),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Suggestions', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 10),
                          for (final suggestion in suggestions)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('•  '),
                                  Expanded(child: Text('$suggestion')),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (result['ai_enabled'] != true)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.wifi_off_outlined),
                        title: const Text('AI suggestions unavailable'),
                        subtitle: const Text('Connect to the internet and add your Groq key to get wording suggestions. The checklist above works offline.'),
                        trailing: IconButton(
                          tooltip: 'Retry',
                          onPressed: _loading ? null : _analyze,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  FilledButton.icon(
                    onPressed: _reviewChanges,
                    icon: const Icon(Icons.rate_review_outlined),
                    label: Text(
                      changes.isEmpty ? 'Review extracted resume' : 'Review ${changes.length} suggested changes',
                    ),
                  ),
                  const SizedBox(height: 16),
                  ExpansionTile(
                    title: const Text('Extracted text'),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SelectableText(widget.extractedText),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReviewSuggestedChangesScreen extends StatefulWidget {
  final String fileName;
  final String originalText;
  final List<Map<String, dynamic>> changes;

  const ReviewSuggestedChangesScreen({
    super.key,
    required this.fileName,
    required this.originalText,
    required this.changes,
  });

  @override
  State<ReviewSuggestedChangesScreen> createState() =>
      _ReviewSuggestedChangesScreenState();
}

class _ReviewSuggestedChangesScreenState extends State<ReviewSuggestedChangesScreen> {
  final Set<String> _accepted = {};
  bool _saving = false;

  String get _updatedText {
    var result = widget.originalText;
    for (final change in widget.changes) {
      final id = '${change['id']}';
      if (_accepted.contains(id)) {
        final original = '${change['original']}';
        final suggested = '${change['suggested']}';
        if (original.isNotEmpty && result.contains(original)) {
          result = result.replaceFirst(original, suggested);
        }
      }
    }
    return result;
  }

  Future<void> _export() async {
    setState(() => _saving = true);
    PdfDocument? document;
    try {
      document = PdfDocument();
      document.pageSettings.size = PdfPageSize.a4;
      document.pageSettings.margins.all = 44;
      final page = document.pages.add();
      PdfTextElement(
        text: _updatedText,
        font: PdfStandardFont(PdfFontFamily.helvetica, 10),
        brush: PdfSolidBrush(PdfColor(35, 40, 48)),
      ).draw(
        page: page,
        bounds: Rect.fromLTWH(0, 0, 507, 750),
        format: PdfLayoutFormat(layoutType: PdfLayoutType.paginate),
      );
      final bytes = Uint8List.fromList(await document.save());
      final safeName = widget.fileName.replaceAll(RegExp(r'\.pdf$', caseSensitive: false), '');
      await FilePicker.saveFile(
        fileName: '${safeName}_reviewed.pdf',
        bytes: bytes,
        mimeType: 'application/pdf',
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not save the reviewed PDF: $error')),
        );
      }
    } finally {
      document?.dispose();
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Review suggested changes')),
        body: SafeArea(
          child: Column(
            children: [
              if (widget.changes.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Wrap(
                    spacing: 8,
                    children: [
                      OutlinedButton(
                        onPressed: () => setState(() => _accepted.clear()),
                        child: const Text('Reject all'),
                      ),
                      FilledButton.tonal(
                        onPressed: () => setState(
                          () => _accepted.addAll(widget.changes.map((item) => '${item['id']}')),
                        ),
                        child: const Text('Accept all'),
                      ),
                    ],
                  ),
                ),
              Expanded(
                child: widget.changes.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(28),
                          child: Text(
                            'No wording changes were generated. Your extracted resume text is preserved unchanged.',
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: widget.changes.length,
                        itemBuilder: (context, index) {
                          final change = widget.changes[index];
                          final id = '${change['id']}';
                          final accepted = _accepted.contains(id);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Original'),
                                  Text('${change['original']}'),
                                  const SizedBox(height: 12),
                                  const Text('Suggested'),
                                  Text('${change['suggested']}'),
                                  SwitchListTile(
                                    contentPadding: EdgeInsets.zero,
                                    title: Text(accepted ? 'Accepted' : 'Rejected'),
                                    value: accepted,
                                    onChanged: (value) => setState(() {
                                      if (value) {
                                        _accepted.add(id);
                                      } else {
                                        _accepted.remove(id);
                                      }
                                    }),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _saving ? null : _export,
                    icon: const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(_saving ? 'Preparing…' : 'Save reviewed PDF'),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
