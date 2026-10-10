import 'package:flutter/material.dart';

import '../../resume_data.dart';
import '../../resume_preview_screen.dart';
import '../../services/draft_storage.dart';
import '../../theme/app_theme.dart';

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
                  const Icon(Icons.description_outlined, size: 48, color: AppColors.muted),
                  const SizedBox(height: 12),
                  const Text('Your saved resumes will appear here.', style: TextStyle(color: AppColors.muted)),
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
                    return Card(
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
                        title: Text(resume.name.isEmpty ? 'Untitled resume' : resume.name),
                        subtitle: Text(resume.updatedAt.isEmpty ? 'Saved on this device' : 'Updated ${resume.updatedAt.substring(0, 10)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ResumePreviewScreen(resumeData: resume))).then((_) => _refresh()),
                      ),
                    );
                  },
                ),
              ),
  );
}
