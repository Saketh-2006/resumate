import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:resumate_ai/api_service.dart';
import 'package:resumate_ai/main.dart';
import 'package:resumate_ai/resume_data.dart';
import 'package:resumate_ai/resume_preview_screen.dart';

void main() {
  testWidgets('welcome page leads to the workspace', (tester) async {
    await tester.pumpWidget(const ResumateApp());
    await tester.tap(find.text('Start your resume'));
    await tester.pumpAndSettle();
    expect(find.text('Create a new resume'), findsOneWidget);
    expect(find.text('Upload a resume'), findsOneWidget);
  });

  test('resume checklist works offline without a Groq key in the build', () async {
    final result = await ApiService.analyzeResume(
      'Jane Doe jane@example.com\nEducation\nB.Tech\nSkills\nDart, Flutter',
    );
    expect(result['ai_enabled'], isFalse);
    expect(result['score'], 60); // contact, education, skills of 5 checks
  });

  testWidgets('preview AI button opens the AI menu', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: ResumePreviewScreen(resumeData: ResumeData(name: 'Test')),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('AI help (needs internet)'));
    await tester.pumpAndSettle();
    expect(find.text('Polish whole resume'), findsOneWidget);
  });
}
