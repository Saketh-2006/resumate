import 'package:flutter/material.dart';

import '../../api_service.dart';

/// Lets a user provide their own key without bundling it in the app package.
Future<bool> requestGroqKey(BuildContext context) async {
  if (await ApiService.hasApiKey()) return true;
  if (!context.mounted) return false;
  final controller = TextEditingController();
  try {
    final key = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Set up AI features'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your Groq API key. It is stored securely on this device and sent to Groq when you use AI actions.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              obscureText: true,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
                labelText: 'Groq API key',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Save key'),
          ),
        ],
      ),
    );
    if (key == null || key.isEmpty) return false;
    await ApiService.saveApiKey(key);
    return true;
  } finally {
    controller.dispose();
  }
}
