import 'dart:convert';

import 'package:flutter/material.dart';

import 'ai_assistant_screen.dart';
import 'api_service.dart';
import 'edit_resume_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';
import 'services/latex_export_service.dart';
import 'services/latex_resume_service.dart';
import 'services/pdf_export_service.dart';
import 'resume_templates.dart';
import 'template_screen.dart';

class ResumePreviewScreen extends StatefulWidget {
  final ResumeData resumeData;

  const ResumePreviewScreen({super.key, required this.resumeData});

  @override
  State<ResumePreviewScreen> createState() => _ResumePreviewScreenState();
}

class _ResumePreviewScreenState extends State<ResumePreviewScreen>
    with SingleTickerProviderStateMixin {
  bool _saving = false;
  bool _exporting = false;
  bool _polishing = false;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1350),
  )..forward();

  ResumeTemplateOption get _template => resumeTemplates.firstWhere(
        (item) => item.id == widget.resumeData.templateId,
        orElse: () => resumeTemplates.first,
      );

  Color get _accent => Color(
        widget.resumeData.customAccentColor ?? _template.color.toARGB32(),
      );
  double get _fontScale => widget.resumeData.fontScale;

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Widget _animateBlock(Widget child, int order) {
    final start = (order * .085).clamp(0.0, .62).toDouble();
    final end = (start + .36).clamp(.36, 1.0).toDouble();
    return AnimatedBuilder(
      animation: _entrance,
      child: child,
      builder: (context, child) {
        final progress = ((_entrance.value - start) / (end - start))
            .clamp(0.0, 1.0)
            .toDouble();
        final value = Curves.easeOutCubic.transform(progress);
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 14 * (1 - value)),
            child: child,
          ),
        );
      },
    );
  }

  Widget _buildHeader(ResumeData resume) {
    final showPhoto = resume.profilePhotoData.isNotEmpty &&
        _template.layout != 'ats';
    final name = resume.name.isEmpty ? 'Your Name' : resume.name;
    final contact = [resume.email, resume.phone, resume.location]
        .where((item) => item.isNotEmpty)
        .join('  •  ');
    final links = [resume.linkedin, resume.github, resume.portfolio]
        .where((item) => item.isNotEmpty)
        .join('  •  ');
    final titleStyle = TextStyle(
      color: _accent,
      fontSize: (_template.layout == 'editorial' ? 31 : 27) * _fontScale,
      fontWeight: FontWeight.w700,
      fontFamily: _template.layout == 'editorial' ? 'serif' : null,
    );
    final photo = showPhoto
        ? CircleAvatar(
            radius: _template.layout == 'banner' ? 72 : 76,
            backgroundColor: Colors.white,
            child: CircleAvatar(
              radius: _template.layout == 'banner' ? 68 : 72,
              backgroundImage: MemoryImage(base64Decode(resume.profilePhotoData)),
            ),
          )
        : null;

    if (_template.layout == 'banner') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: _accent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: titleStyle.copyWith(color: Colors.white)),
                  if (contact.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(contact, style: const TextStyle(color: Colors.white, fontSize: 11)),
                  ],
                  if (links.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(links, style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ],
                ],
              ),
            ),
            if (photo != null) ...[const SizedBox(width: 14), photo],
          ],
        ),
      );
    }

    if (_template.layout == 'centered') {
      return Column(
        children: [
          if (photo != null) ...[photo, const SizedBox(height: 12)],
          Text(name, textAlign: TextAlign.center, style: titleStyle),
          if (contact.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(contact, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
          if (links.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(links, textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: _accent)),
          ],
          const SizedBox(height: 10),
          Container(height: 2, color: _accent.withValues(alpha: .65)),
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: titleStyle),
              const SizedBox(height: 8),
              if (contact.isNotEmpty) Text(contact, style: const TextStyle(fontSize: 11)),
              if (links.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(links, style: TextStyle(fontSize: 10, color: _accent)),
              ],
            ],
          ),
        ),
        if (photo != null) ...[const SizedBox(width: 16), photo],
      ],
    );
  }

  Future<void> _saveDraft({bool returnHome = false}) async {
    setState(() => _saving = true);
    try {
      await DraftStorage().save(widget.resumeData);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume saved on this device.')),
      );
      if (returnHome) Navigator.popUntil(context, (route) => route.isFirst);
    } catch (error) {
      _showError('Could not save this resume: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final result = await PdfExportService.save(widget.resumeData);
      if (!mounted || result == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF saved.')),
      );
    } catch (error) {
      _showError('Could not export the PDF: $error');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  Future<void> _polishResume() async {
    final consent = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send resume details for AI editing?'),
        content: const Text(
          'This sends your resume fields—including your name, email, phone, location, education, and work history—to Groq (gpt-oss-120b). Your profile photo is excluded. The AI will suggest clearer English without adding facts. Review every change before applying it.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Continue and send')),
        ],
      ),
    );
    if (consent != true || !mounted) return;

    setState(() => _polishing = true);
    try {
      final facts = widget.resumeData.toJson()
        ..remove('profilePhotoData')
        ..remove('profilePhotoPath')
        ..remove('id')
        ..remove('updatedAt');
      facts['templateColor'] = _accent.toARGB32();
      final response = await ApiService.generateResume(facts);
      final polishedJson = response['resume_data'] as Map<String, dynamic>;
      final polished = ResumeData.fromJson(polishedJson);
      final review = StringBuffer('Review the suggested wording before applying it.\n\n');
      if (polished.summary.trim().isNotEmpty) {
        review.writeln('PROFILE\n${polished.summary}\n');
      }
      for (var i = 0; i < polished.experiences.length; i++) {
        final item = polished.experiences[i];
        if (item.description.trim().isNotEmpty) {
          review.writeln('EXPERIENCE · ${item.jobTitle}\n${item.description}\n');
        }
      }
      for (var i = 0; i < polished.projects.length; i++) {
        final item = polished.projects[i];
        if (item.description.trim().isNotEmpty) {
          review.writeln('PROJECT · ${item.name}\n${item.description}\n');
        }
      }
      for (final item in polished.achievements) {
        if (item.description.trim().isNotEmpty) {
          review.writeln('ACHIEVEMENT · ${item.title}\n${item.description}\n');
        }
      }
      if (!mounted) return;
      final accepted = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Review AI-written resume'),
          content: SizedBox(
            width: 620,
            height: 440,
            child: SingleChildScrollView(child: SelectableText(review.toString())),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Discard suggestions')),
            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Apply reviewed wording')),
          ],
        ),
      );
      if (accepted != true || !mounted) return;
      final current = widget.resumeData;
      current.summary = polished.summary;
      for (var i = 0; i < current.experiences.length && i < polished.experiences.length; i++) {
        current.experiences[i].description = polished.experiences[i].description;
      }
      for (var i = 0; i < current.projects.length && i < polished.projects.length; i++) {
        current.projects[i].description = polished.projects[i].description;
      }
      for (var i = 0; i < current.achievements.length && i < polished.achievements.length; i++) {
        current.achievements[i].description = polished.achievements[i].description;
      }
      await DraftStorage().save(current);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviewed AI wording applied.')),
      );
    } catch (error) {
      _showError('AI resume writing is unavailable: $error');
    } finally {
      if (mounted) setState(() => _polishing = false);
    }
  }

  Future<void> _saveLatexSource() async {
    final source = LatexResumeService.create(widget.resumeData);
    try {
      await LatexExportService.saveSource(source, widget.resumeData.name);
    } catch (error) {
      _showError('Could not save the LaTeX source: $error');
    }
  }

  Future<void> _edit() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditResumeScreen(resumeData: widget.resumeData),
      ),
    );
    if (mounted) {
      await DraftStorage().save(widget.resumeData);
      setState(() {});
    }
  }

  Future<void> _openSurgicalEdit() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _SurgicalEditSheet(
        resume: widget.resumeData,
        onApplied: () async {
          await DraftStorage().save(widget.resumeData);
          if (mounted) setState(() {});
        },
      ),
    );
  }

  void _askAi() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AiAssistantScreen(resumeData: widget.resumeData),
      ),
    );
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resume = widget.resumeData;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resume preview'),
        actions: [
          IconButton(
            tooltip: 'Change template',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TemplateScreen(resumeData: resume),
                ),
              );
              if (mounted) setState(() {});
            },
            icon: const Icon(Icons.palette_outlined),
          ),
          IconButton(
            tooltip: 'Save draft',
            onPressed: _saving ? null : () => _saveDraft(),
            icon: _saving
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 760),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(36, 38, 36, 42),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        _template.layout == 'ats' ? 0 : 10,
                      ),
                      border: switch (_template.layout) {
                        'sidebar' => Border(
                            left: BorderSide(color: _accent, width: 8),
                            top: BorderSide(color: _accent.withValues(alpha: .3)),
                            right: const BorderSide(color: Color(0xFFE4E7EC)),
                            bottom: const BorderSide(color: Color(0xFFE4E7EC)),
                          ),
                        'split' => Border(
                            top: BorderSide(color: _accent, width: 5),
                            left: BorderSide(color: _accent.withValues(alpha: .35)),
                            right: BorderSide(color: _accent.withValues(alpha: .35)),
                            bottom: BorderSide(color: _accent.withValues(alpha: .35)),
                          ),
                        _ => Border.all(color: const Color(0xFFE4E7EC)),
                      },
                      boxShadow: _template.layout == 'ats'
                          ? const []
                          : const [
                              BoxShadow(
                                color: Color(0x12000000),
                                blurRadius: 18,
                                offset: Offset(0, 6),
                              ),
                            ],
                    ),
                    child: DefaultTextStyle(
                      style: TextStyle(
                        color: const Color(0xFF29303C),
                        fontFamily: _template.layout == 'editorial' ? 'serif' : null,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _animateBlock(_buildHeader(resume), 0),
                          const SizedBox(height: 24),
                          if (resume.summary.trim().isNotEmpty)
                            _section(
                              'Profile',
                              [_entry('', [resume.summary])],
                              order: 1,
                            ),
                          if (resume.education.isNotEmpty)
                            _section(
                              'Education',
                              [
                                if (resume.schoolName.isNotEmpty ||
                                    resume.tenthPercentage.isNotEmpty)
                                  _entry('Secondary School', [
                                    resume.schoolName,
                                    if (resume.tenthPercentage.isNotEmpty)
                                      '10th: ${resume.tenthPercentage}',
                                  ]),
                                if (resume.intermediateInstitution.isNotEmpty ||
                                    resume.intermediateMarks.isNotEmpty)
                                  _entry('Intermediate', [
                                    resume.intermediateInstitution,
                                    if (resume.intermediateMarks.isNotEmpty)
                                      'Marks: ${resume.intermediateMarks}',
                                  ]),
                                ...resume.education.map((item) {
                                final title = [item.degree, item.branch]
                                    .where((value) => value.isNotEmpty)
                                    .join(' · ');
                                return _entry(title, [
                                  item.college,
                                  item.location,
                                  if (item.startYear.isNotEmpty || item.endYear.isNotEmpty)
                                    '${item.startYear} – ${item.endYear}',
                                  if (item.cgpa.isNotEmpty) item.cgpa,
                                ]);
                              }),
                              ],
                              order: 2,
                            ),
                          if (resume.education.isEmpty &&
                              (resume.schoolName.isNotEmpty ||
                                  resume.tenthPercentage.isNotEmpty ||
                                  resume.intermediateInstitution.isNotEmpty ||
                                  resume.intermediateMarks.isNotEmpty))
                            _section('Education', [
                              if (resume.schoolName.isNotEmpty ||
                                  resume.tenthPercentage.isNotEmpty)
                                _entry('Secondary School', [
                                  resume.schoolName,
                                  if (resume.tenthPercentage.isNotEmpty)
                                    '10th: ${resume.tenthPercentage}',
                                ]),
                              if (resume.intermediateInstitution.isNotEmpty ||
                                  resume.intermediateMarks.isNotEmpty)
                                _entry('Intermediate', [
                                  resume.intermediateInstitution,
                                  if (resume.intermediateMarks.isNotEmpty)
                                    'Marks: ${resume.intermediateMarks}',
                                ]),
                            ], order: 2),
                          if (resume.skills.isNotEmpty)
                            _section(
                              'Skills',
                              [
                                Wrap(
                                  spacing: 7,
                                  runSpacing: 7,
                                  children: resume.skills
                                      .map(
                                        (item) => Chip(
                                          label: Text(item),
                                          visualDensity: VisualDensity.compact,
                                          side: BorderSide.none,
                                          backgroundColor: _accent.withValues(alpha: .09),
                                        ),
                                      )
                                      .toList(),
                                ),
                              ],
                              order: 3,
                            ),
                          if (resume.projects.isNotEmpty)
                            _section(
                              'Projects',
                              resume.projects
                                  .map((item) => _entry(item.name, [
                                        item.description,
                                        if (item.technologies.isNotEmpty)
                                          'Technologies: ${item.technologies}',
                                        item.projectLink,
                                  ]))
                                  .toList(),
                              order: 4,
                            ),
                          if (resume.experiences.isNotEmpty)
                            _section(
                              'Experience',
                              resume.experiences.map((item) {
                                final dates = [
                                  if (item.startDate.isNotEmpty) item.startDate,
                                  if (item.currentlyWorking)
                                    'Present'
                                  else if (item.endDate.isNotEmpty)
                                    item.endDate,
                                ].join(' – ');
                                return _entry(
                                  '${item.jobTitle}${item.company.isEmpty ? '' : ' · ${item.company}'}',
                                  [item.location, dates, item.description],
                                );
                              }).toList(),
                              order: 5,
                            ),
                          if (resume.certifications.isNotEmpty)
                            _section(
                              'Certifications',
                              resume.certifications
                                  .map((item) => _entry(item.name, [
                                        item.organization,
                                        item.issueDate,
                                        item.credentialUrl,
                                  ]))
                                  .toList(),
                              order: 6,
                            ),
                          if (resume.achievements.isNotEmpty)
                            _section(
                              'Achievements',
                              resume.achievements
                                  .map((item) => _entry(item.title, [
                                        item.organization,
                                        item.date,
                                        item.description,
                                  ]))
                                  .toList(),
                              order: 7,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 12,
                runSpacing: 10,
                alignment: WrapAlignment.center,
                children: [
                  OutlinedButton.icon(
                    onPressed: _edit,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Edit details'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _askAi,
                    icon: const Icon(Icons.auto_awesome_outlined),
                    label: const Text('Ask AI'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _openSurgicalEdit,
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Quick edit'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _polishing ? null : _polishResume,
                    icon: _polishing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_polishing ? 'Writing…' : 'AI polish resume'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saveLatexSource,
                    icon: const Icon(Icons.code),
                    label: const Text('Download .tex'),
                  ),
                  OutlinedButton.icon(
                    onPressed: _saving ? null : () => _saveDraft(returnHome: true),
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save resume'),
                  ),
                  FilledButton.icon(
                    onPressed: _exporting ? null : _export,
                    icon: _exporting
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.picture_as_pdf_outlined),
                    label: Text(_exporting ? 'Preparing PDF…' : 'Export PDF'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<Widget> items, {required int order}) =>
      _animateBlock(Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(
          crossAxisAlignment: _template.layout == 'centered'
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.start,
          children: [
            Text(
              title.toUpperCase(),
              textAlign: _template.layout == 'centered' ? TextAlign.center : null,
              style: TextStyle(
                color: _accent,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
                fontSize: 12 * _fontScale,
              ),
            ),
            const SizedBox(height: 2),
            Container(height: 1, color: _accent.withValues(alpha: .55)),
            const SizedBox(height: 8),
            ...items,
          ],
        ),
      ), order);

  Widget _entry(String title, List<String> details) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12 * _fontScale),
              ),
            for (final detail in details.where((value) => value.trim().isNotEmpty))
              Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Text(detail, style: TextStyle(fontSize: 11 * _fontScale, height: 1.35)),
              ),
          ],
        ),
      );
}

class _SurgicalEditSheet extends StatefulWidget {
  const _SurgicalEditSheet({required this.resume, required this.onApplied});
  final ResumeData resume;
  final Future<void> Function() onApplied;

  @override
  State<_SurgicalEditSheet> createState() => _SurgicalEditSheetState();
}

class _SurgicalEditSheetState extends State<_SurgicalEditSheet> {
  final _instruction = TextEditingController();
  String _target = 'summary';
  String? _suggestion;
  String? _lastRequest;
  bool _sending = false;

  @override
  void dispose() { _instruction.dispose(); super.dispose(); }

  List<(String, String)> get _targets => [
    if (widget.resume.summary.trim().isNotEmpty) ('summary', 'Profile summary'),
    for (var i = 0; i < widget.resume.experiences.length; i++)
      if (widget.resume.experiences[i].description.trim().isNotEmpty) ('experience:$i', 'Experience · ${widget.resume.experiences[i].jobTitle}'),
    for (var i = 0; i < widget.resume.projects.length; i++)
      if (widget.resume.projects[i].description.trim().isNotEmpty) ('project:$i', 'Project · ${widget.resume.projects[i].name}'),
    for (var i = 0; i < widget.resume.achievements.length; i++)
      if (widget.resume.achievements[i].description.trim().isNotEmpty) ('achievement:$i', 'Achievement · ${widget.resume.achievements[i].title}'),
  ];

  String _textFor(String key) {
    if (key == 'summary') return widget.resume.summary;
    final parts = key.split(':');
    final index = int.parse(parts[1]);
    return switch (parts[0]) {
      'experience' => widget.resume.experiences[index].description,
      'project' => widget.resume.projects[index].description,
      _ => widget.resume.achievements[index].description,
    };
  }

  Future<void> _send() async {
    final instruction = _instruction.text.trim();
    if (instruction.isEmpty || _targets.isEmpty) return;
    setState(() { _sending = true; _suggestion = null; _lastRequest = instruction; });
    try {
      final original = _textFor(_target);
      final response = await ApiService.surgicalEdit(originalText: original, instruction: instruction);
      if (!mounted) return;
      setState(() { _suggestion = response['suggested'] as String?; });
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not prepare that edit: $error')));
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _apply() async {
    final suggestion = _suggestion;
    if (suggestion == null) return;
    setState(() => _setText(_target, suggestion));
    await widget.onApplied();
    if (mounted) setState(() { _suggestion = null; _instruction.clear(); });
  }

  void _setText(String key, String text) {
    if (key == 'summary') { widget.resume.summary = text; return; }
    final parts = key.split(':'); final index = int.parse(parts[1]);
    switch (parts[0]) {
      case 'experience': widget.resume.experiences[index].description = text; break;
      case 'project': widget.resume.projects[index].description = text; break;
      default: widget.resume.achievements[index].description = text; break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final targets = _targets;
    if (targets.isEmpty) {
      return SafeArea(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.chat_bubble_outline, size: 30), const SizedBox(height: 10),
        const Text('Add a profile summary or a description first to make a quick edit.'),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
      ])));
    }
    if (!targets.any((item) => item.$1 == _target)) _target = targets.first.$1;
    return SafeArea(child: Padding(
      padding: EdgeInsets.fromLTRB(20, 6, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 620), child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Expanded(child: Text('Quick resume edit', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))), IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close))]),
        const Text('Choose one section. Review the suggestion before applying it.', style: TextStyle(color: Colors.black54)),
        const SizedBox(height: 10),
        DropdownButtonFormField<String>(initialValue: _target, decoration: const InputDecoration(labelText: 'Section'), items: [for (final item in targets) DropdownMenuItem(value: item.$1, child: Text(item.$2, overflow: TextOverflow.ellipsis))], onChanged: (value) => setState(() { if (value != null) { _target = value; _suggestion = null; } })),
        const SizedBox(height: 9),
        if (_lastRequest != null) Padding(padding: const EdgeInsets.only(bottom: 7), child: Text('You: $_lastRequest', maxLines: 2, overflow: TextOverflow.ellipsis)),
        if (_suggestion != null) Container(width: double.infinity, padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Theme.of(context).colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(12)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Current text', style: TextStyle(fontSize: 11, color: Colors.black54, fontWeight: FontWeight.w600)),
          Text(_textFor(_target)), const SizedBox(height: 8),
          const Text('Suggested edit', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 5),
          Text(_suggestion!), const SizedBox(height: 10),
          Row(children: [TextButton(onPressed: () => setState(() => _suggestion = null), child: const Text('Discard')), const Spacer(), FilledButton.icon(onPressed: _apply, icon: const Icon(Icons.check), label: const Text('Apply edit'))]),
        ])),
        const SizedBox(height: 9),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Expanded(child: TextField(controller: _instruction, minLines: 1, maxLines: 3, textInputAction: TextInputAction.send, onSubmitted: (_) => _send(), decoration: const InputDecoration(hintText: 'e.g. Make this more concise', border: OutlineInputBorder()))),
          const SizedBox(width: 8),
          IconButton.filled(onPressed: _sending ? null : _send, tooltip: 'Suggest a small edit', icon: _sending ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.send)),
        ]),
      ])),
    ));
  }
}
