import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';

/// App-wide light/dark choice, persisted on the device.
final themeMode = ValueNotifier(ThemeMode.system);
const _themeKey = 'resumate.themeMode';

Future<void> loadThemeMode() async {
  try {
    final saved = (await SharedPreferences.getInstance()).getString(_themeKey);
    themeMode.value = ThemeMode.values.firstWhere(
      (mode) => mode.name == saved,
      orElse: () => ThemeMode.system,
    );
  } catch (_) {
    // Preferences unavailable: follow the system setting.
  }
}

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return IconButton(
      tooltip: dark ? 'Switch to light paper' : 'Switch to night paper',
      onPressed: () async {
        themeMode.value = dark ? ThemeMode.light : ThemeMode.dark;
        try {
          await (await SharedPreferences.getInstance())
              .setString(_themeKey, themeMode.value.name);
        } catch (_) {}
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) => RotationTransition(
          turns: Tween(begin: .6, end: 1.0).animate(animation),
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          dark ? Icons.wb_sunny_outlined : Icons.nightlight_outlined,
          key: ValueKey(dark),
          color: context.colors.ink,
        ),
      ),
    );
  }
}

/// Handwritten text that writes itself left to right, line by line, with a
/// pen nib riding the tip of the ink.
class WritingText extends StatefulWidget {
  const WritingText(
    this.text, {
    super.key,
    this.size = 34,
    this.delay = Duration.zero,
    this.color,
    this.msPerChar = 45,
  });

  final String text;
  final double size;
  final Duration delay;
  final Color? color;
  final int msPerChar;

  @override
  State<WritingText> createState() => _WritingTextState();
}

class _WritingTextState extends State<WritingText>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: Duration(
      milliseconds: widget.msPerChar * widget.text.length + 200,
    ),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontFamily: AppFonts.hand,
      fontWeight: FontWeight.w700,
      fontSize: widget.size,
      height: 1.05,
      color: widget.color ?? context.colors.ink,
    );
    final lines = widget.text.split('\n');
    final widths = [
      for (final line in lines)
        (TextPainter(
          text: TextSpan(text: line, style: style),
          textDirection: TextDirection.ltr,
          textScaler: MediaQuery.textScalerOf(context),
        )..layout()).width,
    ];
    final total = widths.fold<double>(0, (a, b) => a + b);
    return Semantics(
      label: widget.text,
      child: ExcludeSemantics(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            var ink = Curves.easeInOut.transform(_controller.value) * total;
            final rows = <Widget>[];
            for (var i = 0; i < lines.length; i++) {
              final shown = ink.clamp(0.0, widths[i]);
              ink -= widths[i];
              final writing = shown > 0 && shown < widths[i];
              rows.add(Stack(
                clipBehavior: Clip.none,
                children: [
                  ClipRect(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      widthFactor: widths[i] == 0 ? 1 : shown / widths[i],
                      child: Text(lines[i], style: style, softWrap: false),
                    ),
                  ),
                  if (writing)
                    Positioned(
                      left: shown - 4,
                      bottom: widget.size * .12 +
                          math.sin(_controller.value * 90) * 2,
                      child: _Pen(size: widget.size * .55),
                    ),
                ],
              ));
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: rows,
            );
          },
        ),
      ),
    );
  }
}

class _Pen extends StatelessWidget {
  const _Pen({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: -.15,
    alignment: Alignment.bottomLeft,
    child: Icon(Icons.edit, size: size, color: context.colors.coral),
  );
}

/// A wavy ink stroke that draws itself, for underlining headings.
class InkUnderline extends StatelessWidget {
  const InkUnderline({
    super.key,
    this.width = 140,
    this.delay = Duration.zero,
    this.color,
  });

  final double width;
  final Duration delay;
  final Color? color;

  @override
  Widget build(BuildContext context) => _Delayed(
    delay: delay,
    duration: const Duration(milliseconds: 700),
    builder: (t) => CustomPaint(
      size: Size(width, 10),
      painter: _StrokePainter(
        progress: Curves.easeOut.transform(t),
        color: color ?? context.colors.coral,
      ),
    ),
  );
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({required this.progress, required this.color});
  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()..moveTo(0, size.height * .6);
    const waves = 4;
    for (var i = 0; i < waves; i++) {
      final x0 = size.width * i / waves;
      final x1 = size.width * (i + 1) / waves;
      path.quadraticBezierTo(
        (x0 + x1) / 2,
        i.isEven ? 0 : size.height,
        x1,
        size.height * .5,
      );
    }
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_StrokePainter old) =>
      old.progress != progress || old.color != color;
}

/// Fades and lifts its child into place after [delay], like a note being
/// set down on the page. Use increasing delays for a staggered list.
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.delay = Duration.zero});
  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) => _Delayed(
    delay: delay,
    duration: const Duration(milliseconds: 520),
    builder: (t) {
      final v = Curves.easeOutCubic.transform(t);
      return Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
      );
    },
  );
}

/// Runs a 0→1 animation once, after a delay.
class _Delayed extends StatefulWidget {
  const _Delayed({
    required this.delay,
    required this.duration,
    required this.builder,
  });

  final Duration delay;
  final Duration duration;
  final Widget Function(double t) builder;

  @override
  State<_Delayed> createState() => _DelayedState();
}

class _DelayedState extends State<_Delayed> with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(vsync: this, duration: widget.duration);

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (_, _) => widget.builder(_controller.value),
  );
}

/// Hero illustration: a resume sheet being filled in by a pencil — the title
/// is written, then each line scribbles in, then a stamp lands.
class WritingSheet extends StatefulWidget {
  const WritingSheet({super.key});

  @override
  State<WritingSheet> createState() => _WritingSheetState();
}

class _WritingSheetState extends State<WritingSheet>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 4200),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final dark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: 240,
      height: 210,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          final stamp = Curves.elasticOut.transform(
            ((t - .82) / .18).clamp(0.0, 1.0),
          );
          return Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // A second sheet peeking out underneath.
              Transform.rotate(
                angle: .07,
                child: _sheet(dark ? c.line : const Color(0xFFEDE3D0), c, 150, 185),
              ),
              Transform.rotate(
                angle: -.035,
                child: _sheet(
                  dark ? c.sheet : const Color(0xFFFFFDF7),
                  c,
                  150,
                  185,
                  child: CustomPaint(
                    size: const Size(150, 185),
                    painter: _ScribblePainter(progress: t, ink: c.ink, accent: c.accent),
                  ),
                ),
              ),
              if (stamp > 0)
                Positioned(
                  right: -4,
                  bottom: 6,
                  child: Transform.rotate(
                    angle: .14,
                    child: Transform.scale(
                      scale: stamp,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          border: Border.all(color: c.coral, width: 2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'you’ve got this',
                          style: TextStyle(
                            fontFamily: AppFonts.hand,
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: c.coral,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _sheet(Color color, Palette c, double w, double h, {Widget? child}) =>
      Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(3),
          border: Border.all(color: c.line),
          boxShadow: const [
            BoxShadow(color: Color(0x22000000), blurRadius: 14, offset: Offset(2, 8)),
          ],
        ),
        child: child,
      );
}

class _ScribblePainter extends CustomPainter {
  _ScribblePainter({required this.progress, required this.ink, required this.accent});
  final double progress;
  final Color ink;
  final Color accent;

  // Each stroke: start x, y, width, is-title.
  static const _strokes = [
    (16.0, 30.0, 92.0, true),
    (16.0, 62.0, 112.0, false),
    (16.0, 78.0, 84.0, false),
    (16.0, 106.0, 104.0, false),
    (16.0, 122.0, 118.0, false),
    (16.0, 138.0, 70.0, false),
    (16.0, 162.0, 96.0, false),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final writing = (progress / .8).clamp(0.0, 1.0);
    final per = 1 / _strokes.length;
    Offset? tip;
    for (var i = 0; i < _strokes.length; i++) {
      final local = ((writing - i * per) / per).clamp(0.0, 1.0);
      if (local == 0) break;
      final (x, y, w, title) = _strokes[i];
      final path = _squiggle(x, y, w, title ? 6.0 : 3.0, title ? 9 : 14);
      final paint = Paint()
        ..color = title ? accent : ink.withValues(alpha: .55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = title ? 3.2 : 1.6
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final metric in path.computeMetrics()) {
        final part = metric.extractPath(0, metric.length * local);
        canvas.drawPath(part, paint);
        if (local < 1) {
          tip = metric.getTangentForOffset(metric.length * local)?.position;
        }
      }
    }
    tip ??= progress < .8 ? null : const Offset(118, 168);
    if (tip != null) _pencil(canvas, tip, lift: progress >= .8 ? (progress - .8) * 60 : 0);
  }

  // Cursive-looking loops along a line.
  Path _squiggle(double x, double y, double w, double amp, int loops) {
    final path = Path()..moveTo(x, y);
    final step = w / loops;
    for (var i = 0; i < loops; i++) {
      final x0 = x + step * i;
      path.cubicTo(
        x0 + step * .3, y - amp * (1 + (i % 3) * .25),
        x0 + step * .9, y - amp * .4,
        x0 + step * .55, y + amp * .3,
      );
      path.quadraticBezierTo(x0 + step * .8, y + amp * .5, x0 + step, y);
    }
    return path;
  }

  void _pencil(Canvas canvas, Offset tip, {double lift = 0}) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy - lift);
    canvas.rotate(-.75);
    final body = RRect.fromRectAndRadius(const Rect.fromLTWH(10, -4, 62, 8), const Radius.circular(2));
    canvas.drawRRect(body, Paint()..color = const Color(0xFFE9B949));
    canvas.drawRect(const Rect.fromLTWH(64, -4, 8, 8), Paint()..color = const Color(0xFFE38C70));
    final cone = Path()
      ..moveTo(0, 0)
      ..lineTo(10, -4)
      ..lineTo(10, 4)
      ..close();
    canvas.drawPath(cone, Paint()..color = const Color(0xFFF1D7B0));
    canvas.drawCircle(Offset.zero, 1.6, Paint()..color = ink);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_ScribblePainter old) =>
      old.progress != progress || old.ink != ink || old.accent != accent;
}
