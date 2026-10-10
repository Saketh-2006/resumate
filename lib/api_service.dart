import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _configuredBaseUrl = String.fromEnvironment(
    'RESUMATE_API_BASE_URL',
  );

  static String get baseUrl {
    if (_configuredBaseUrl.isNotEmpty) return _configuredBaseUrl;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8000';
    }
    return 'http://127.0.0.1:8000';
  }

  static Future<String> checkBackend() async {
    final data = await _request('/health', method: 'GET');
    return data['status'] as String? ?? 'unknown';
  }

  static Future<Map<String, dynamic>> analyzeResume(String resumeText) =>
      _request('/api/resume/analyze', body: {'resume_text': resumeText});

  static Future<Map<String, dynamic>> improveText(String text) =>
      _request('/api/ai/improve', body: {'text': text});

  static Future<Map<String, dynamic>> generateSummary(
    Map<String, dynamic> resumeData,
  ) =>
      _request('/api/ai/summary', body: {'resume_data': resumeData});

  static Future<Map<String, dynamic>> askAssistant({
    required String message,
    required String resumeContext,
  }) =>
      _request(
        '/api/assistant/chat',
        body: {'message': message, 'resume_context': resumeContext},
        timeout: const Duration(minutes: 3),
      );

  static Future<Map<String, dynamic>> generateResume(
    Map<String, dynamic> resumeData,
  ) =>
      _request('/api/resume/generate', body: {'resume_data': resumeData});

  static Future<Map<String, dynamic>> surgicalEdit({
    required String originalText,
    required String instruction,
  }) => _request('/api/resume/surgical-edit', body: {
    'original_text': originalText,
    'instruction': instruction,
  });

  static Future<List<int>> compileLatexPdf(String latexSource) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl/api/resume/pdf'),
          headers: const {'Content-Type': 'application/json'},
          body: jsonEncode({'latex_source': latexSource}),
        )
        .timeout(const Duration(seconds: 60));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'LaTeX PDF compilation failed.';
      try {
        final decoded = jsonDecode(response.body);
        if (decoded is Map<String, dynamic> && decoded['detail'] is String) {
          message = decoded['detail'] as String;
        }
      } on FormatException {
        // Keep the generic message when the backend did not return JSON.
      }
      throw Exception(message);
    }
    return response.bodyBytes;
  }

  static Future<Map<String, dynamic>> _request(
    String path, {
    String method = 'POST',
    Map<String, Object?>? body,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    try {
      final uri = Uri.parse('$baseUrl$path');
      final response = method == 'GET'
          ? await http.get(uri).timeout(const Duration(seconds: 25))
          : await http
              .post(
                uri,
                headers: const {'Content-Type': 'application/json'},
                body: jsonEncode(body),
              )
              .timeout(timeout);
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('The backend returned an invalid response.');
      }
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final detail = decoded['detail'];
        throw Exception(
          detail is String ? detail : 'Backend returned HTTP ${response.statusCode}.',
        );
      }
      return decoded;
    } on Exception catch (error) {
      throw Exception('Could not complete the request. $error');
    }
  }
}
