import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumate_ai/features/resume/resume_editor_page.dart';
import 'package:resumate_ai/resume_data.dart';
import 'package:resumate_ai/resume_preview_screen.dart';
import 'package:resumate_ai/services/draft_storage.dart';
import 'package:resumate_ai/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Education search includes new branches and AP autonomous colleges',
    (tester) async {
      tester.view.physicalSize = const Size(900, 1200);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.light, home: const ResumeEditorPage()),
      );
      final personalFields = find.byType(TextFormField);
      await tester.enterText(personalFields.at(0), 'Test User');
      await tester.enterText(personalFields.at(1), 'test@example.com');
      await tester.enterText(personalFields.at(2), '9876543210');
      await tester.enterText(personalFields.at(3), 'Visakhapatnam');
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Branch / specialization *'));
      await tester.pumpAndSettle();
      expect(
        find.text('Artificial Intelligence and Machine Learning (AI & ML)'),
        findsOneWidget,
      );
      expect(
        find.text('Artificial Intelligence and Data Science (AI & DS)'),
        findsOneWidget,
      );
      await tester.tap(
        find.text('Artificial Intelligence and Machine Learning (AI & ML)'),
      );
      await tester.pumpAndSettle();

      final collegeField = find.byType(TextFormField).first;
      await tester.tap(collegeField);
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).last, 'Bapatla');
      await tester.pumpAndSettle();
      expect(find.text('Bapatla Engineering College'), findsOneWidget);
      await tester.tap(find.text('Bapatla Engineering College'));
      await tester.pumpAndSettle();
      expect(find.text('Bapatla Engineering College'), findsOneWidget);
    },
  );

  test(
    'selected branch and institution persist in saved resume data',
    () async {
      SharedPreferences.setMockInitialValues({});
      final resume = ResumeData(
        name: 'Test User',
        education: [
          EducationData(
            degree: 'B.Tech.',
            branch: 'Artificial Intelligence and Data Science (AI & DS)',
            college: 'Bapatla Engineering College',
          ),
        ],
      );

      final storage = DraftStorage();
      await storage.save(resume);
      final restored = (await storage.getAll()).single.education.single;
      expect(
        restored.branch,
        'Artificial Intelligence and Data Science (AI & DS)',
      );
      expect(restored.college, 'Bapatla Engineering College');
    },
  );

  testWidgets('selected education details display in resume preview', (
    tester,
  ) async {
    final resume = ResumeData(
      name: 'Test User',
      education: [
        EducationData(
          degree: 'B.Tech.',
          branch: 'Artificial Intelligence and Data Science (AI & DS)',
          college: 'Bapatla Engineering College',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: ResumePreviewScreen(resumeData: resume),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Artificial Intelligence and Data Science (AI & DS)'),
      findsOneWidget,
    );
    expect(find.text('Bapatla Engineering College'), findsOneWidget);
  });
}
