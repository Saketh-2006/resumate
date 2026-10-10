import 'dart:convert';

import 'package:flutter/material.dart';

import 'ai_assistant_screen.dart';
import 'api_service.dart';
import 'edit_resume_screen.dart';
import 'resume_data.dart';
import 'services/draft_storage.dart';
import 'services/latex_export_service.dart';
import 'services/pdf_export_service.dart';
import 'resume_templates.dart';

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
  String? _latexSource;
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
      if (_latexSource != null) {
        try {
          final pdf = await ApiService.compileLatexPdf(_latexSource!);
          await LatexExportService.savePdf(pdf, widget.resumeData.name);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('LaTeX PDF is ready to save.')),
            );
          }
          return;
        } catch (error) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('LaTeX compiler unavailable; creating the app PDF instead. $error')),
            );
          }
        }
      }
      final result = await PdfExportService.save(widget.resumeData);
      if (!mounted || result == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF is ready at your chosen location.')),
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
          'This sends your resume fields—including your name, email, phone, location, education, and work history—to the ResuMate backend and its configured OpenAI model. Your profile photo is excluded. Your OpenAI account may incur usage charges. The AI will suggest clearer English without adding facts. Review every change before applying it.',
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
      final polishedJson = response['resume_data'];
      final source = response['latex_source'];
      if (polishedJson is! Map<String, dynamic> || source is! String || source.isEmpty) {
        throw const FormatException('The AI did not return a complete resume and LaTeX source.');
      }
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
      setState(() => _latexSource = source);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviewed AI wording applied. LaTeX source is ready to download.')),
      );
    } catch (error) {
      _showError('AI resume writing is unavailable: $error');
    } finally {
      if (mounted) setState(() => _polishing = false);
    }
  }

  Future<void> _saveLatexSource() async {
    final source = _latexSource;
    if (source == null) return;
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
    if (mounted) setState(() {});
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
            onPressed: () => Navigator.pushNamed(
              context,
              '/templates',
              arguments: resume,
            ),
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
                    onPressed: _polishing ? null : _polishResume,
                    icon: _polishing
                        ? const SizedBox.square(
                            dimension: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.auto_awesome),
                    label: Text(_polishing ? 'Writing…' : 'AI polish resume'),
                  ),
                  if (_latexSource != null)
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
