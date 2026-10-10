import 'package:flutter/material.dart';
import 'features/home/welcome_page.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ResumateApp());
}

class ResumateApp extends StatelessWidget {
  const ResumateApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Resumate',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.light,
    home: const WelcomePage(),
  );
}
