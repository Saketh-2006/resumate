import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

class ResumeDoll extends StatelessWidget {
  const ResumeDoll({super.key});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 210,
    height: 176,
    child: Stack(alignment: Alignment.center, children: [
      Positioned(bottom: 2, child: Transform.rotate(angle: -.045, child: Container(width: 114, height: 145, decoration: BoxDecoration(color: const Color(0xFFF3E8D4), border: Border.all(color: const Color(0xFFD9CBB4)), borderRadius: BorderRadius.circular(4), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 9, offset: Offset(3, 5))]), child: const Padding(padding: EdgeInsets.fromLTRB(18, 21, 14, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('MY RESUME', style: TextStyle(fontSize: 9, letterSpacing: 1.3, color: AppColors.accent, fontWeight: FontWeight.bold)), SizedBox(height: 10), _PaperLine(width: 70), _PaperLine(width: 58), SizedBox(height: 8), _PaperLine(width: 70), _PaperLine(width: 52), _PaperLine(width: 61)]))))),
      Positioned(left: 25, bottom: 4, child: CustomPaint(size: const Size(35, 27), painter: LeafPainter())),
      const Positioned(top: 0, child: _DollFigure()),
      Positioned(right: 4, top: 22, child: Transform.rotate(angle: .1, child: Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6), decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(4)), child: const Text('YOU’VE GOT THIS', style: TextStyle(color: Colors.white, fontSize: 8, letterSpacing: .7, fontWeight: FontWeight.bold))))),
    ]),
  );
}

class _PaperLine extends StatelessWidget {
  const _PaperLine({required this.width}); final double width;
  @override Widget build(BuildContext context) => Container(width: width, height: 2, margin: const EdgeInsets.only(bottom: 6), color: const Color(0xFFD8CBB7));
}

class _DollFigure extends StatelessWidget {
  const _DollFigure();
  @override Widget build(BuildContext context) => SizedBox(width: 98, height: 126, child: Stack(alignment: Alignment.center, children: [
    Positioned(top: 52, child: Container(width: 69, height: 70, decoration: const BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.vertical(top: Radius.circular(25), bottom: Radius.circular(12))))),
    Positioned(top: 34, child: Container(width: 44, height: 49, decoration: const BoxDecoration(color: Color(0xFFEFC9A8), shape: BoxShape.circle))),
    Positioned(top: 25, child: Container(width: 48, height: 26, decoration: const BoxDecoration(color: Color(0xFF45372F), borderRadius: BorderRadius.vertical(top: Radius.circular(28), bottom: Radius.circular(9))))),
    const Positioned(top: 54, left: 35, child: _Eye()), const Positioned(top: 54, right: 35, child: _Eye()),
    Positioned(top: 66, child: Container(width: 10, height: 3, decoration: BoxDecoration(color: AppColors.coral, borderRadius: BorderRadius.circular(4)))),
    Positioned(top: 97, child: Row(children: [Container(width: 12, height: 24, decoration: BoxDecoration(color: const Color(0xFFEFC9A8), borderRadius: BorderRadius.circular(8))), const SizedBox(width: 36), Container(width: 12, height: 24, decoration: BoxDecoration(color: const Color(0xFFEFC9A8), borderRadius: BorderRadius.circular(8)))])),
    Positioned(top: 71, child: Container(width: 14, height: 2, color: const Color(0xFFF5D9B9))),
  ]));
}

class _Eye extends StatelessWidget { const _Eye(); @override Widget build(BuildContext context) => Container(width: 3, height: 4, decoration: const BoxDecoration(color: AppColors.ink, shape: BoxShape.circle)); }

class LeafPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) { final p = Paint()..color = AppColors.accent..style = PaintingStyle.stroke..strokeWidth = 2; final path = Path()..moveTo(2, size.height)..quadraticBezierTo(size.width / 2, 0, size.width - 2, 2); canvas.drawPath(path,p); canvas.drawLine(Offset(3,size.height-1),Offset(size.width-3,4),p); }
  @override bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
