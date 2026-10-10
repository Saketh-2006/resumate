import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/paper_widgets.dart';
import '../chat/career_assistant_page.dart';
import '../resume/resume_editor_page.dart';
import '../../upload_resume_screen.dart';
import '../resume/my_resumes_page.dart';

class WorkspacePage extends StatelessWidget {
  const WorkspacePage({super.key});

  @override
  Widget build(BuildContext context) {
    void open(Widget page) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    final choices = [
      (Icons.note_add_outlined, 'Create a new resume', 'Build it section by section, at your own pace.', 'START FRESH', () => open(const ResumeEditorPage())),
      (Icons.folder_open_outlined, 'My resumes', 'Open, review, and download resumes saved on this device.', null, () => open(const MyResumesPage())),
      (Icons.file_upload_outlined, 'Upload a resume', 'Bring an existing PDF resume and get suggestions.', null, () => open(const UploadResumeScreen())),
      (Icons.forum_outlined, 'Chat with the career assistant', 'Help with resumes, interviews, and applications.', 'NEEDS INTERNET', () => open(const CareerAssistantPage())),
    ];
    return Scaffold(
      appBar: AppBar(actions: const [ThemeToggle(), SizedBox(width: 8)]),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(30, 4, 22, 32),
              children: [
                const PageHeading(
                  'Where to begin?',
                  subtitle: 'Pick up a fresh page, bring a resume you already have, or talk through your next step.',
                ),
                const SizedBox(height: 26),
                for (var i = 0; i < choices.length; i++)
                  FadeSlideIn(
                    delay: Duration(milliseconds: 450 + 110 * i),
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: _IndexCard(
                        // Alternate a hair of tilt so the cards look hand-placed.
                        tilt: i.isEven ? -.006 : .005,
                        icon: choices[i].$1,
                        title: choices[i].$2,
                        subtitle: choices[i].$3,
                        tag: choices[i].$4,
                        onTap: choices[i].$5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _IndexCard extends StatefulWidget {
  const _IndexCard({required this.tilt, required this.icon, required this.title, required this.subtitle, required this.onTap, this.tag});
  final double tilt;
  final IconData icon;
  final String title, subtitle;
  final String? tag;
  final VoidCallback onTap;

  @override
  State<_IndexCard> createState() => _IndexCardState();
}

class _IndexCardState extends State<_IndexCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedScale(
      scale: _pressed ? .97 : 1,
      duration: const Duration(milliseconds: 120),
      child: Transform.rotate(
        angle: _pressed ? 0 : widget.tilt,
        child: Material(
          color: c.sheet,
          elevation: _pressed ? 1 : 3,
          shadowColor: Colors.black26,
          borderRadius: BorderRadius.circular(6),
          child: InkWell(
            onTap: widget.onTap,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            borderRadius: BorderRadius.circular(6),
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                // Index-card red rule along the top.
                border: Border(top: BorderSide(color: c.coral.withValues(alpha: .6), width: 3)),
              ),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(color: c.accentSoft, shape: BoxShape.circle),
                  child: Icon(widget.icon, color: c.accent),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if (widget.tag != null)
                      Text(widget.tag!, style: TextStyle(fontSize: 10, color: c.accent, letterSpacing: 1.2, fontWeight: FontWeight.w700)),
                    Text(widget.title, style: TextStyle(fontFamily: AppFonts.hand, fontSize: 24, height: 1.15, color: c.ink, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(widget.subtitle, style: TextStyle(fontSize: 13, height: 1.4, color: c.muted)),
                  ]),
                ),
                Icon(Icons.arrow_forward_rounded, size: 18, color: c.muted),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
