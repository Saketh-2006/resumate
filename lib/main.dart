
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'education_screen.dart';
import 'home_screen.dart';
import 'resume_data.dart';
import 'resume_preview_screen.dart';
import 'template_screen.dart';
import 'services/draft_storage.dart';

void main() {
  runApp(const ResumateApp());
}

class ResumateApp extends StatefulWidget {
  const ResumateApp({super.key});

  @override
  State<ResumateApp> createState() => _ResumateAppState();
}

class _ResumateAppState extends State<ResumateApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((preferences) {
      if (!mounted) return;
      setState(() {
        _themeMode = preferences.getBool('resumate.darkMode') == true
            ? ThemeMode.dark
            : ThemeMode.light;
      });
    }).catchError((_) {});
  }

  void _toggleTheme() {
    setState(
      () => _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light,
    );
    SharedPreferences.getInstance().then(
      (preferences) => preferences.setBool(
        'resumate.darkMode',
        _themeMode == ThemeMode.dark,
      ),
    );
  }

  Widget _home() => HomeScreen(
        isDark: _themeMode == ThemeMode.dark,
        onToggleTheme: _toggleTheme,
        onCreateResume: (screenContext) {
          Navigator.push(
            screenContext,
            MaterialPageRoute(
              builder: (_) => ResumeBuilderScreen(resumeData: ResumeData()),
            ),
          );
        },
      );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ResuMate AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4657B8),
          surface: const Color(0xFFF7F8FC),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8FC),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFFF7F8FC),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFDCE1EB)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFFDCE1EB)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF4657B8), width: 1.6),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF9CA8FF),
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF131722),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          backgroundColor: Color(0xFF131722),
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1B2130),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF343D50)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF343D50)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(14)),
            borderSide: BorderSide(color: Color(0xFF9CA8FF), width: 1.6),
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        ),
        useMaterial3: true,
        pageTransitionsTheme: PageTransitionsTheme(
          builders: {
            TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.iOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.linux: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.macOS: FadeUpwardsPageTransitionsBuilder(),
            TargetPlatform.windows: FadeUpwardsPageTransitionsBuilder(),
          },
        ),
      ),
      themeMode: _themeMode,
      onGenerateRoute: (settings) {
        if (settings.name == '/templates') {
          final resume = settings.arguments! as ResumeData;
          return MaterialPageRoute<void>(
            builder: (_) => TemplateScreen(resumeData: resume),
          );
        }
        if (settings.name == '/preview') {
          final resume = settings.arguments! as ResumeData;
          return MaterialPageRoute<void>(
            builder: (_) => ResumePreviewScreen(resumeData: resume),
          );
        }
        return null;
      },
      home: _StartupGate(
        homeBuilder: _home,
        onToggleTheme: _toggleTheme,
        isDark: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class _StartupGate extends StatefulWidget {
  final Widget Function() homeBuilder;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const _StartupGate({
    required this.homeBuilder,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<_StartupGate> createState() => _StartupGateState();
}

class _StartupGateState extends State<_StartupGate> {
  late final Future<bool> _onboardingComplete = SharedPreferences.getInstance()
      .then((preferences) => preferences.getBool('resumate.onboardingComplete') ?? false)
      .catchError((_) => false);

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
        future: _onboardingComplete,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const _SplashScreen();
          if (snapshot.data!) return widget.homeBuilder();
          return _OnboardingScreen(
            homeBuilder: widget.homeBuilder,
            onToggleTheme: widget.onToggleTheme,
            isDark: widget.isDark,
          );
        },
      );
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.description_outlined,
                size: 60,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 14),
              Text('ResuMate AI', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 6),
              const Text('Build. Improve. Get Resume-Ready.'),
              const SizedBox(height: 20),
              const SizedBox.square(
                dimension: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ],
          ),
        ),
      );
}

class _OnboardingScreen extends StatefulWidget {
  final Widget Function() homeBuilder;
  final VoidCallback onToggleTheme;
  final bool isDark;

  const _OnboardingScreen({
    required this.homeBuilder,
    required this.onToggleTheme,
    required this.isDark,
  });

  @override
  State<_OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<_OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;

  static const _pages = [
    (
      icon: Icons.edit_document,
      title: 'Create your resume',
      description: 'Build a professional resume from your real information in a few clear steps.',
    ),
    (
      icon: Icons.find_in_page_outlined,
      title: 'Improve your existing resume',
      description: 'Review structure and suggestions before accepting any wording changes.',
    ),
    (
      icon: Icons.auto_awesome_outlined,
      title: 'Get careful AI assistance',
      description: 'Improve clarity while keeping your experience and achievements truthful.',
    ),
  ];

  Future<void> _finish() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool('resumate.onboardingComplete', true);
    } catch (_) {
      // Onboarding can be completed for this session even if storage is unavailable.
    }
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => widget.homeBuilder()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(onPressed: _finish, child: const Text('Skip')),
            IconButton(
              tooltip: widget.isDark ? 'Light mode' : 'Dark mode',
              onPressed: widget.onToggleTheme,
              icon: Icon(widget.isDark ? Icons.light_mode : Icons.dark_mode_outlined),
            ),
          ],
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 20),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _page == _pages.length - 1
                    ? _finish
                    : () => _controller.nextPage(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOut,
                        ),
                child: Text(
                  _page == _pages.length - 1 ? 'Get started' : 'Next',
                ),
              ),
            ),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 620),
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _controller,
                      itemCount: _pages.length,
                      onPageChanged: (page) => setState(() => _page = page),
                      itemBuilder: (context, index) {
                        final item = _pages[index];
                        return Padding(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 52,
                                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                                child: Icon(
                                  item.icon,
                                  size: 48,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 28),
                              Text(
                                item.title,
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 12),
                              Text(item.description, textAlign: TextAlign.center),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _pages.length,
                      (index) => Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _page
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
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

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _uploadOldResume(BuildContext context) async {
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result.isEmpty) {
      return;
    }

    final file = result.single;

    try {
      final pdfBytes = await file.readAsBytes();
      if (pdfBytes.isEmpty) {
        throw const FormatException('The selected PDF is empty.');
      }
      final document = PdfDocument(
        inputBytes: pdfBytes,
      );

      String extractedText;

      try {
        extractedText =
            PdfTextExtractor(document).extractText();
      } finally {
        document.dispose();
      }

      if (!context.mounted) {
        return;
      }

      showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(file.name),
            content: SizedBox(
              width: 500,
              height: 400,
              child: SingleChildScrollView(
                child: SelectableText(
                  extractedText.trim().isEmpty
                      ? 'No text found in this PDF.'
                      : extractedText,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Close'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      if (!context.mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not read the PDF: $error',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 500,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .primaryContainer,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Icon(
                      Icons.description_outlined,
                      size: 48,
                      color: Theme.of(context)
                          .colorScheme
                          .primary,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Welcome to ResuMate AI',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 12),

                  Text(
                    'Build. Improve. Get Resume-Ready.',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Create a professional resume '
                    'with AI assistance.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge,
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 36),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ResumeBuilderScreen(
                              resumeData: ResumeData(),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.add),
                      label: const Text(
                        'Create New Resume',
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _uploadOldResume(context);
                      },
                      icon: const Icon(
                        Icons.upload_file,
                      ),
                      label: const Text(
                        'Upload Old Resume',
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

class ResumeBuilderScreen extends StatefulWidget {
  final ResumeData resumeData;

  const ResumeBuilderScreen({
    super.key,
    required this.resumeData,
  });

  @override
  State<ResumeBuilderScreen> createState() =>
      _ResumeBuilderScreenState();
}

class _ResumeBuilderScreenState
    extends State<ResumeBuilderScreen> {
  ResumeData get resumeData => widget.resumeData;

  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final locationController = TextEditingController();
  final linkedinController = TextEditingController();
  final githubController = TextEditingController();
  final portfolioController = TextEditingController();
  final schoolNameController = TextEditingController();
  final tenthPercentageController = TextEditingController();
  final intermediateInstitutionController = TextEditingController();
  final intermediateMarksController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    locationController.dispose();
    linkedinController.dispose();
    githubController.dispose();
    portfolioController.dispose();
    schoolNameController.dispose();
    tenthPercentageController.dispose();
    intermediateInstitutionController.dispose();
    intermediateMarksController.dispose();

    super.dispose();
  }

  Widget buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
        validator: validator,
      ),
    );
  }

  String? validateOptionalUrl(String? value) {
    final url = value?.trim() ?? '';
    if (url.isNotEmpty &&
        !RegExp(r'^(https?://)?[^.\s]+\.[^\s]+$').hasMatch(url)) {
      return 'Enter a valid website address';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Personal Information',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personal Information',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight:
                                FontWeight.bold,
                          ),
                    ),

                    const SizedBox(height: 8),

                    const Text(
                      'Enter your personal details '
                      'for your resume.',
                    ),

                    const SizedBox(height: 28),

                    buildTextField(
                      label: 'Full Name *',
                      hint: 'e.g. Andra Saketh',
                      controller: nameController,
                      validator: (value) {
                        if (value == null ||
                            value.trim().isEmpty) {
                          return 'Please enter your name';
                        }

                        return null;
                      },
                    ),

                    buildTextField(
                      label: 'Email *',
                      hint:
                          'e.g. saketh@example.com',
                      controller: emailController,
                      keyboardType:
                          TextInputType.emailAddress,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty ||
                            !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$')
                                .hasMatch(email)) {
                          return 'Enter a valid email address';
                        }

                        return null;
                      },
                    ),

                    buildTextField(
                      label: 'Phone Number *',
                      hint:
                          'e.g. +91 9876543210',
                      controller: phoneController,
                      keyboardType:
                          TextInputType.phone,
                      validator: (value) {
                        final phone = value?.trim() ?? '';
                        if (phone.isEmpty ||
                            phone.replaceAll(RegExp(r'\D'), '').length < 7) {
                          return 'Enter a valid phone number';
                        }

                        return null;
                      },
                    ),

                    buildTextField(
                      label: 'Location *',
                      hint:
                          'e.g. Vijayawada, Andhra Pradesh',
                      controller:
                          locationController,
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Please enter your city and country/region'
                          : null,
                    ),

                    buildTextField(
                      label: 'LinkedIn',
                      hint:
                          'e.g. linkedin.com/in/yourname',
                      controller:
                          linkedinController,
                      keyboardType: TextInputType.url,
                      validator: validateOptionalUrl,
                    ),

                    buildTextField(
                      label: 'GitHub',
                      hint:
                          'e.g. github.com/yourname',
                      controller:
                          githubController,
                      keyboardType: TextInputType.url,
                      validator: validateOptionalUrl,
                    ),

                    buildTextField(
                      label: 'Portfolio (optional)',
                      hint: 'e.g. yourname.dev',
                      controller: portfolioController,
                      keyboardType: TextInputType.url,
                      validator: validateOptionalUrl,
                    ),

                    const SizedBox(height: 8),
                    Text(
                      'Schooling (optional)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    buildTextField(
                      label: 'School name (10th)',
                      hint: 'e.g. City High School',
                      controller: schoolNameController,
                    ),
                    buildTextField(
                      label: '10th percentage or marks',
                      hint: 'e.g. 92% or 552/600',
                      controller: tenthPercentageController,
                      keyboardType: TextInputType.text,
                    ),
                    buildTextField(
                      label: 'Intermediate college / school',
                      hint: 'e.g. Sunrise Junior College',
                      controller: intermediateInstitutionController,
                    ),
                    buildTextField(
                      label: 'Intermediate marks or percentage',
                      hint: 'e.g. 945/1000 or 94.5%',
                      controller: intermediateMarksController,
                    ),

                    const SizedBox(height: 10),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: () async {
                          if (!_formKey.currentState!
                              .validate()) {
                            return;
                          }

                          resumeData.name =
                              nameController.text.trim();

                          resumeData.email =
                              emailController.text.trim();

                          resumeData.phone =
                              phoneController.text.trim();

                          resumeData.location =
                              locationController.text.trim();

                          resumeData.linkedin =
                              linkedinController.text.trim();

                          resumeData.github =
                              githubController.text.trim();

                          resumeData.portfolio =
                              portfolioController.text.trim();

                          resumeData.schoolName =
                              schoolNameController.text.trim();
                          resumeData.tenthPercentage =
                              tenthPercentageController.text.trim();
                          resumeData.intermediateInstitution =
                              intermediateInstitutionController.text.trim();
                          resumeData.intermediateMarks =
                              intermediateMarksController.text.trim();

                          await DraftStorage().save(resumeData);
                          if (!context.mounted) return;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EducationScreen(
                                resumeData:
                                    resumeData,
                              ),
                            ),
                          );
                        },
                        child: const Text(
                          'Save & Continue',
                        ),
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
}
