import 'package:flutter/material.dart';

import 'ai_assistant_screen.dart';
import 'edit_resume_screen.dart';
import 'resume_data.dart';
import 'resume_preview_screen.dart';
import 'services/draft_storage.dart';
import 'services/pdf_export_service.dart';
import 'template_screen.dart';
import 'resume_templates.dart';
import 'upload_resume_screen.dart';

class HomeScreen extends StatefulWidget {
  final ValueChanged<BuildContext> onCreateResume;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const HomeScreen({
    super.key,
    required this.onCreateResume,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final _storage = DraftStorage();
  List<ResumeData> _resumes = [];
  bool _loading = true;
  String? _loadError;
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );
  late final Animation<double> _heroFade = CurvedAnimation(
    parent: _entrance,
    curve: const Interval(0, .62, curve: Curves.easeOutCubic),
  );
  late final List<Animation<double>> _cardFades = List.generate(
    3,
    (index) => CurvedAnimation(
      parent: _entrance,
      curve: Interval(.12 + index * .16, .66 + index * .1, curve: Curves.easeOutCubic),
    ),
  );

  @override
  void initState() {
    super.initState();
    _entrance.forward();
    _refresh();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      final drafts = await _storage.getAll();
      if (mounted) setState(() => _resumes = drafts);
    } catch (error) {
      if (mounted) setState(() => _loadError = error.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _duplicate(ResumeData resume) async {
    await _storage.duplicate(resume);
    await _refresh();
  }

  Future<void> _exportResume(ResumeData resume) async {
    try {
      final savedAt = await PdfExportService.save(resume);
      if (!mounted || savedAt == null) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF is ready at your chosen location.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not export the PDF: $error')),
      );
    }
  }

  Future<void> _delete(ResumeData resume) async {
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete this resume?'),
        content: const Text(
          'Are you sure you want to delete this resume? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (approved != true) return;
    await _storage.delete(resume.id);
    await _refresh();
  }

  void _openResume(ResumeData resume) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ResumePreviewScreen(resumeData: resume)),
    ).then((_) => _refresh());
  }

  void _editResume(ResumeData resume) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => EditResumeScreen(resumeData: resume)),
    ).then((_) => _refresh());
  }

  Widget _featureCard({
    required IconData icon,
    required String title,
    required String description,
    required String action,
    required VoidCallback onPressed,
    bool primary = false,
    int animationIndex = 0,
  }) =>
      FadeTransition(
        opacity: _cardFades[animationIndex],
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, .08),
            end: Offset.zero,
          ).animate(_cardFades[animationIndex]),
          child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .65),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(icon, size: 25, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(height: 16),
              Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 7),
              Expanded(child: Text(description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4))),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: primary
                    ? FilledButton(onPressed: onPressed, child: Text(action))
                    : OutlinedButton(onPressed: onPressed, child: Text(action)),
              ),
            ],
          ),
        ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: const Icon(Icons.description_outlined, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text('ResuMate AI', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
          actions: [
            IconButton(
              tooltip:
                  widget.isDark ? 'Switch to light mode' : 'Switch to dark mode',
              onPressed: widget.onToggleTheme,
              icon: Icon(
                widget.isDark ? Icons.light_mode : Icons.dark_mode_outlined,
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1120),
              child: CustomScrollView(
                slivers: [
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: FadeTransition(
                        opacity: _heroFade,
                        child: SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, .08),
                            end: Offset.zero,
                          ).animate(_heroFade),
                          child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('YOUR CAREER TOOLKIT', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, letterSpacing: 1.3)),
                          const SizedBox(height: 8),
                          Text('Make your next move\nwith confidence.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800, height: 1.12)),
                          const SizedBox(height: 8),
                          Text('Create a polished resume that tells your story clearly.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                        ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.crossAxisExtent > 850
                            ? 3
                            : constraints.crossAxisExtent > 560
                                ? 2
                                : 1;
                        return SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: columns,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                            childAspectRatio: columns == 1 ? 1.32 : 1.12,
                          ),
                          delegate: SliverChildListDelegate([
                            _featureCard(
                              icon: Icons.auto_awesome_outlined,
                              title: 'Create a resume',
                              description:
                                  'Build a professional resume from the information you provide.',
                              action: 'Create resume',
                              onPressed: () => widget.onCreateResume(context),
                              primary: true,
                              animationIndex: 0,
                            ),
                            _featureCard(
                              icon: Icons.upload_file_outlined,
                              title: 'Improve an existing resume',
                              description:
                                  'Upload a PDF, check its structure, and review suggested wording changes.',
                              action: 'Upload PDF',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const UploadResumeScreen(),
                                ),
                              ),
                              animationIndex: 1,
                            ),
                            _featureCard(
                              icon: Icons.chat_bubble_outline,
                              title: 'AI resume assistant',
                              description:
                                  'Ask for help with resume wording, projects, skills, and structure.',
                              action: 'Ask ResuMate AI',
                              onPressed: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const AiAssistantScreen(),
                                ),
                              ),
                              animationIndex: 2,
                            ),
                          ]),
                        );
                      },
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              'My resumes',
                              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          TextButton.icon(
                            onPressed: _refresh,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_loading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (_loadError != null)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Card(
                          child: ListTile(
                            title: const Text('Could not load saved resumes'),
                            subtitle: Text(_loadError!),
                            trailing: IconButton(
                              onPressed: _refresh,
                              icon: const Icon(Icons.refresh),
                            ),
                          ),
                        ),
                      ),
                    )
                  else if (_resumes.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 36),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              children: [
                                const Icon(Icons.description_outlined, size: 42),
                                const SizedBox(height: 10),
                                Text(
                                  'No resumes yet',
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Create your first professional resume in a few steps.',
                                ),
                                const SizedBox(height: 14),
                                FilledButton(
                                  onPressed: () => widget.onCreateResume(context),
                                  child: const Text('Create your first resume'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
                      sliver: SliverList.separated(
                        itemCount: _resumes.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final resume = _resumes[index];
                          final template = resumeTemplates.firstWhere(
                            (item) => item.id == resume.templateId,
                            orElse: () => resumeTemplates.first,
                          );
                          final date = DateTime.tryParse(resume.updatedAt);
                          final updated = date == null
                              ? ''
                              : ' · Updated ${date.toLocal().toString().split(' ').first}';
                          return Card(
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                              side: BorderSide(
                                color: Theme.of(context).colorScheme.outlineVariant.withValues(alpha: .65),
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor:
                                        template.color.withValues(alpha: .12),
                                    child: Icon(
                                      Icons.description_outlined,
                                      color: template.color,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          resume.name.isEmpty
                                              ? 'Untitled resume'
                                              : '${resume.name} — Resume',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                        const SizedBox(height: 3),
                                        Text('${template.name} template$updated'),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    tooltip: 'Open preview',
                                    onPressed: () => _openResume(resume),
                                    icon: const Icon(Icons.visibility_outlined),
                                  ),
                                  PopupMenuButton<String>(
                                    tooltip: 'More actions',
                                    onSelected: (value) {
                                      switch (value) {
                                        case 'edit':
                                          _editResume(resume);
                                          break;
                                        case 'duplicate':
                                          _duplicate(resume);
                                          break;
                                        case 'export':
                                          _exportResume(resume);
                                          break;
                                        case 'delete':
                                          _delete(resume);
                                          break;
                                        case 'template':
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => TemplateScreen(
                                                resumeData: resume,
                                              ),
                                            ),
                                          ).then((_) => _refresh());
                                          break;
                                      }
                                    },
                                    itemBuilder: (_) => const [
                                      PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      PopupMenuItem(
                                        value: 'template',
                                        child: Text('Change template'),
                                      ),
                                      PopupMenuItem(
                                        value: 'duplicate',
                                        child: Text('Duplicate'),
                                      ),
                                      PopupMenuItem(
                                        value: 'export',
                                        child: Text('Export PDF'),
                                      ),
                                      PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
}
