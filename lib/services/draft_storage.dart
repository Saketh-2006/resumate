import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../resume_data.dart';

/// Device-local draft storage. The service API can later be backed by Firestore
/// after a Firebase project is configured, without changing the screens.
class DraftStorage {
  static const _storageKey = 'resumate.resumeDrafts.v1';

  Future<List<ResumeData>> getAll() async {
    final preferences = await SharedPreferences.getInstance();
    final stored = preferences.getStringList(_storageKey) ?? const <String>[];
    final drafts = <ResumeData>[];
    for (final item in stored) {
      try {
        final decoded = jsonDecode(item);
        if (decoded is Map<String, dynamic>) {
          drafts.add(ResumeData.fromJson(decoded));
        }
      } on FormatException {
        // Ignore a damaged entry while keeping the other saved drafts usable.
      }
    }
    drafts.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return drafts;
  }

  Future<void> save(ResumeData resume) async {
    final preferences = await SharedPreferences.getInstance();
    final drafts = await getAll();
    resume.id = resume.id.isEmpty
        ? DateTime.now().microsecondsSinceEpoch.toString()
        : resume.id;
    resume.updatedAt = DateTime.now().toIso8601String();
    final index = drafts.indexWhere((item) => item.id == resume.id);
    if (index == -1) {
      drafts.insert(0, resume);
    } else {
      drafts[index] = resume;
    }
    await preferences.setStringList(
      _storageKey,
      drafts.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }

  Future<void> delete(String id) async {
    final preferences = await SharedPreferences.getInstance();
    final drafts = await getAll()..removeWhere((item) => item.id == id);
    await preferences.setStringList(
      _storageKey,
      drafts.map((item) => jsonEncode(item.toJson())).toList(),
    );
  }
}
