import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'workspace_page.dart';
import 'widgets/paper_button.dart';
import 'widgets/resume_doll.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.sheet,
                border: Border.all(color: AppColors.line),
                borderRadius: BorderRadius.circular(5),
                boxShadow: const [
                  BoxShadow(color: Color(0x18000000), blurRadius: 25, offset: Offset(0, 12)),
                ],
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: CustomPaint(painter: PaperRulePainter())),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(34, 28, 34, 34),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [
                          const Icon(Icons.menu_book_rounded, size: 19, color: AppColors.accent),
                          const SizedBox(width: 8),
                          Text('RESUMATE  /  YOUR NEXT CHAPTER', style: Theme.of(context).textTheme.labelSmall?.copyWith(letterSpacing: 1.25, color: AppColors.muted)),
                        ]),
                        const SizedBox(height: 20),
                        const Center(child: ResumeDoll()),
                        const SizedBox(height: 20),
                        Text('A good story\nstarts on paper.', style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: AppColors.ink, height: 1.12, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 12),
                        Text('Let’s make a resume that sounds like you. Take it one step at a time.', style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.muted, height: 1.55)),
                        const SizedBox(height: 24),
                        PaperButton(label: 'Start your resume', icon: Icons.arrow_forward_rounded, onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WorkspacePage()))),
                        const SizedBox(height: 12),
                        const Center(child: Text('No account needed to begin', style: TextStyle(fontSize: 12, color: AppColors.muted))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class PaperRulePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFECE5D8)..strokeWidth = 0.65;
    for (var y = 54.0; y < size.height; y += 34) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
