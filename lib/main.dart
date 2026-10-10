import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'features/home/welcome_page.dart';
import 'theme/app_theme.dart';
import 'theme/paper_widgets.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LicenseRegistry.addLicense(() async* {
    yield LicenseEntryWithLineBreaks(
      ['Lora', 'Caveat'],
      await rootBundle.loadString('assets/fonts/OFL.txt'),
    );
  });
  await loadThemeMode();
  runApp(const ResumateApp());
}

class ResumateApp extends StatelessWidget {
  const ResumateApp({super.key});

  @override
  Widget build(BuildContext context) => ValueListenableBuilder(
    valueListenable: themeMode,
    builder: (context, mode, _) => MaterialApp(
      title: 'Resumate',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: mode,
      home: const WelcomePage(),
    ),
  );
}
