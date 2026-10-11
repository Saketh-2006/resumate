import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../theme/paper_widgets.dart';
import 'workspace_page.dart';
import 'widgets/paper_button.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(32, 12, 24, 28),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.menu_book_rounded, size: 18, color: c.accent),
                    const SizedBox(width: 8),
                    Text(
                      'RESUMATE',
                      style: TextStyle(fontSize: 12, letterSpacing: 2, color: c.muted, fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    const ThemeToggle(),
                  ]),
                  const SizedBox(height: 20),
                  const Center(child: WritingSheet()),
                  const SizedBox(height: 28),
                  const WritingText(
                    'A good story\nstarts on paper.',
                    size: 46,
                    delay: Duration(milliseconds: 300),
                  ),
                  const SizedBox(height: 4),
                  const InkUnderline(width: 170, delay: Duration(milliseconds: 1900)),
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 1700),
                    child: Text(
                      'Let’s make a resume that sounds like you. One page, one step at a time.',
                      style: TextStyle(fontSize: 16, height: 1.6, color: c.muted),
                    ),
                  ),
                  const SizedBox(height: 28),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 2100),
                    child: PaperButton(
                      label: 'Start your resume',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const WorkspacePage()),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 2300),
                    child: Center(
                      child: Text(
                        'No account needed · works offline',
                        style: TextStyle(fontSize: 12, color: c.muted),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
