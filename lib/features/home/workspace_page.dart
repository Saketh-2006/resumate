import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../chat/career_assistant_page.dart';
import '../resume/resume_editor_page.dart';
import '../../upload_resume_screen.dart';
import '../resume/my_resumes_page.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Your workspace', style: TextStyle(fontWeight: FontWeight.w700)), leading: IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back))),
    body: SafeArea(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: ListView(padding: const EdgeInsets.fromLTRB(22, 22, 22, 32), children: [
      Text('Where would you like to begin?', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: context.colors.ink, fontWeight: FontWeight.w700)),
      const SizedBox(height: 8), Text('Pick up a fresh page, bring a resume you already have, or talk through your next step.', style: TextStyle(color: context.colors.muted, height: 1.5)),
      const SizedBox(height: 28),
      _WorkspaceChoice(icon: Icons.note_add_outlined, title: 'Create a new resume', subtitle: 'Build it section by section, at your own pace.', tag: 'START FRESH', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResumeEditorPage()))),
      const SizedBox(height: 13),
      _WorkspaceChoice(icon: Icons.folder_open_outlined, title: 'My resumes', subtitle: 'Open, review, and download resumes saved on this device.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyResumesPage()))),
      const SizedBox(height: 13),
      _WorkspaceChoice(icon: Icons.file_upload_outlined, title: 'Upload a resume', subtitle: 'Bring an existing PDF resume and get suggestions.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UploadResumeScreen()))),
      const SizedBox(height: 13),
      _WorkspaceChoice(icon: Icons.forum_outlined, title: 'Chat with the career assistant', subtitle: 'Get practical help with resumes, interviews, and applications.', onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CareerAssistantPage()))),
      const SizedBox(height: 26),
      Center(child: TextButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.menu_book_outlined, size: 18), label: const Text('Back to the welcome page'), style: TextButton.styleFrom(foregroundColor: context.colors.muted))),
    ])))),
  );
}

class _WorkspaceChoice extends StatelessWidget {
  const _WorkspaceChoice({required this.icon, required this.title, required this.subtitle, required this.onTap, this.tag});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap; final String? tag;
  @override
  Widget build(BuildContext context) => Material(color: context.colors.sheet, borderRadius: BorderRadius.circular(12), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(border: Border.all(color: context.colors.line), borderRadius: BorderRadius.circular(12)), child: Row(children: [Container(width: 48, height: 48, decoration: BoxDecoration(color: context.colors.accentSoft, borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: context.colors.accent)), const SizedBox(width: 15), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [if (tag != null) Padding(padding: const EdgeInsets.only(bottom: 5), child: Text(tag!, style: TextStyle(fontSize: 9, color: context.colors.accent, letterSpacing: 1.2, fontWeight: FontWeight.bold))), Text(title, style: TextStyle(fontSize: 16, color: context.colors.ink, fontWeight: FontWeight.w700)), const SizedBox(height: 4), Text(subtitle, style: TextStyle(fontSize: 13, height: 1.4, color: context.colors.muted))])), const SizedBox(width: 8), Icon(Icons.arrow_forward_ios_rounded, size: 16, color: context.colors.muted)]))));
}
