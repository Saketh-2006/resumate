import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:resumate_ai/resume_data.dart';

void main() {
  test(
    'optional photo path survives draft JSON and old drafts remain valid',
    () {
      final resume = ResumeData(
        name: 'Jordan Lee',
        photoPath: '/private/profile_photos/one.jpg',
      );
      final reopened = ResumeData.fromJson(
        jsonDecode(jsonEncode(resume.toJson())),
      );
      expect(reopened.photoPath, resume.photoPath);

      final oldDraft = ResumeData.fromJson({
        'name': 'Old draft',
        'skills': ['Dart'],
      });
      expect(oldDraft.photoPath, isEmpty);
      expect(oldDraft.skills, ['Dart']);
    },
  );
}
