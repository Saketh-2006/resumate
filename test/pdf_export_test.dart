import 'package:flutter_test/flutter_test.dart';

import 'package:resumate_ai/resume_data.dart';
import 'package:resumate_ai/resume_templates.dart';
import 'package:resumate_ai/services/pdf_export_service.dart';

void main() {
  test('every template exports a PDF offline', () async {
    for (final template in resumeTemplates) {
      final resume = ResumeData(
        name: 'Saketh Test',
        email: 'saketh@example.com',
        education: [EducationData(degree: 'B.Tech.', college: 'Amrita', startYear: '2022', endYear: '2026', cgpa: '8.7')],
        skills: ['Dart', 'Flutter'],
        projects: [ProjectData(name: 'Resumate', description: 'Resume builder')],
      )..templateId = template.id;
      final bytes = await PdfExportService.create(resume);
      expect(String.fromCharCodes(bytes.take(4)), '%PDF', reason: template.id);
    }
  });
}
