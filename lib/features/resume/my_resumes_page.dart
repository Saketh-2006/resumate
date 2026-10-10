import 'package:flutter/material.dart';

import '../../resume_data.dart';
import '../../resume_preview_screen.dart';
import '../../services/draft_storage.dart';
import '../../theme/app_theme.dart';
import '../../theme/paper_widgets.dart';

class MyResumesPage extends StatefulWidget {
  const MyResumesPage({super.key});

  @override
  State<MyResumesPage> createState() => _MyResumesPageState();
}

class _MyResumesPageState extends State<MyResumesPage> {
  final _storage = DraftStorage();
  List<ResumeData> _resumes = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final resumes = await _storage.getAll();
    if (mounted) setState(() { _resumes = resumes; _loading = false; });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('My resumes')),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _resumes.isEmpty
            ? Center(child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.description_outlined, size: 48, color: context.colors.muted),
                  const SizedBox(height: 12),
                  Text('Your saved resumes will appear here.', style: TextStyle(color: context.colors.muted)),
                  const SizedBox(height: 12),
                  FilledButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.add), label: const Text('Create a resume')),
                ]),
              ))
            : RefreshIndicator(
                onRefresh: _refresh,
                child: ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _resumes.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final resume = _resumes[index];
                    return FadeSlideIn(
                      key: ValueKey(resume.id),
                      delay: Duration(milliseconds: 60 * index.clamp(0, 8)),
                      child: Dismissible(
                      key: ValueKey(resume.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.delete_outline, color: context.colors.coral),
                      ),
                      confirmDismiss: (_) => showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete this resume?'),
                          content: const Text('It will be removed from this device.'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Keep')),
                            FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
                          ],
                        ),
                      ),
                      onDismissed: (_) {
                        setState(() => _resumes.remove(resume));
                        _storage.delete(resume.id);
                      },
                      child: Card(
                      color: context.colors.sheet,
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
                        title: Text(resume.name.isEmpty ? 'Untitled resume' : resume.name, style: const TextStyle(fontFamily: AppFonts.hand, fontSize: 22, fontWeight: FontWeight.w700)),
                        subtitle: Text(resume.updatedAt.isEmpty ? 'Saved on this device' : 'Updated ${resume.updatedAt.substring(0, 10)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResumePreviewScreen(resumeData: resume))).then((_) => _refresh()),
                      ),
                    )));
                  },
                ),
              ),
  );
}
