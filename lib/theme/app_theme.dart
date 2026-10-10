import 'package:flutter/material.dart';

/// Notebook palette. Read it with `context.colors` so it follows dark mode.
@immutable
class Palette extends ThemeExtension<Palette> {
  const Palette({
    required this.paper,
    required this.sheet,
    required this.ink,
    required this.muted,
    required this.line,
    required this.margin,
    required this.accent,
    required this.accentSoft,
    required this.coral,
  });

  final Color paper, sheet, ink, muted, line, margin, accent, accentSoft, coral;

  static const light = Palette(
    paper: Color(0xFFF6F1E8),
    sheet: Color(0xFFFFFCF5),
    ink: Color(0xFF282722),
    muted: Color(0xFF77746C),
    line: Color(0xFFE5DED1),
    margin: Color(0x55D9826B),
    accent: Color(0xFF315C4C),
    accentSoft: Color(0xFFE5EDE5),
    coral: Color(0xFFC76D53),
  );

  // Night notebook: warm charcoal paper, chalk-coloured ink.
  static const dark = Palette(
    paper: Color(0xFF1B1A17),
    sheet: Color(0xFF252320),
    ink: Color(0xFFEDE7DB),
    muted: Color(0xFFA29D92),
    line: Color(0xFF39362F),
    margin: Color(0x55C4705A),
    accent: Color(0xFF8CC2A8),
    accentSoft: Color(0xFF2B3A33),
    coral: Color(0xFFE38C70),
  );

  @override
  Palette copyWith() => this;

  @override
  Palette lerp(Palette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return Palette(
      paper: l(paper, other.paper),
      sheet: l(sheet, other.sheet),
      ink: l(ink, other.ink),
      muted: l(muted, other.muted),
      line: l(line, other.line),
      margin: l(margin, other.margin),
      accent: l(accent, other.accent),
      accentSoft: l(accentSoft, other.accentSoft),
      coral: l(coral, other.coral),
    );
  }
}

extension PaletteContext on BuildContext {
  Palette get colors => Theme.of(this).extension<Palette>()!;
}

/// Bundled fonts so the app looks the same offline on every device.
abstract final class AppFonts {
  static const body = 'Lora';
  static const hand = 'Caveat';
}

abstract final class AppTheme {
  static ThemeData get light => _build(Palette.light, Brightness.light);
  static ThemeData get dark => _build(Palette.dark, Brightness.dark);

  static ThemeData _build(Palette c, Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: c.accent,
      brightness: brightness,
      primary: c.accent,
      onPrimary: c.sheet,
      surface: c.sheet,
      onSurface: c.ink,
    );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: c.line),
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      extensions: [c],
      // Transparent so the ruled notebook page behind every route shows.
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: c.sheet,
      fontFamily: AppFonts.body,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: PaperPageTransitionsBuilder(),
          TargetPlatform.iOS: PaperPageTransitionsBuilder(),
          TargetPlatform.macOS: PaperPageTransitionsBuilder(),
          TargetPlatform.windows: PaperPageTransitionsBuilder(),
          TargetPlatform.linux: PaperPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: c.ink,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: AppFonts.hand,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: c.ink,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.accent,
          foregroundColor: c.sheet,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.ink,
        contentTextStyle: TextStyle(color: c.paper, fontFamily: AppFonts.body),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.sheet,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(
          borderSide: BorderSide(color: c.accent, width: 1.5),
        ),
      ),
    );
  }
}

/// New pages slide in like a sheet laid on top of the notebook, with a
/// slight tilt that settles as it lands.
class PaperPageTransitionsBuilder extends PageTransitionsBuilder {
  const PaperPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final enter = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    final under = CurvedAnimation(parent: secondaryAnimation, curve: Curves.easeOut);
    return AnimatedBuilder(
      animation: Listenable.merge([enter, under]),
      child: RuledPaper(child: child),
      builder: (context, child) => Opacity(
        opacity: (1 - under.value * .4) * (.3 + .7 * enter.value),
        child: Transform.translate(
          offset: Offset(0, 36 * (1 - enter.value)),
          child: Transform.rotate(
            angle: .02 * (1 - enter.value),
            child: Transform.scale(
              scale: 1 - .03 * under.value,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  boxShadow: [
                    if (enter.value < 1)
                      BoxShadow(
                        color: Colors.black.withValues(alpha: .18 * (1 - enter.value)),
                        blurRadius: 24,
                      ),
                  ],
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ruled notebook page: horizontal rules plus a red margin line.
class RuledPaper extends StatelessWidget {
  const RuledPaper({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => CustomPaint(
    painter: _RulePainter(context.colors),
    child: child,
  );
}

class _RulePainter extends CustomPainter {
  _RulePainter(this.c);
  final Palette c;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = c.paper);
    final rule = Paint()
      ..color = c.line.withValues(alpha: .7)
      ..strokeWidth = .8;
    for (var y = 96.0; y < size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), rule);
    }
    canvas.drawLine(
      const Offset(14, 0),
      Offset(14, size.height),
      Paint()
        ..color = c.margin
        ..strokeWidth = 1.2,
    );
  }

  @override
  bool shouldRepaint(_RulePainter old) => old.c != c;
}
