import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../../theme/app_theme.dart';

class CareerAssistantPage extends StatefulWidget {
  const CareerAssistantPage({super.key});
  @override
  State<CareerAssistantPage> createState() => _CareerAssistantPageState();
}

class _CareerAssistantPageState extends State<CareerAssistantPage> {
  static const _storage = FlutterSecureStorage();
  static const _endpoint = 'https://api.groq.com/openai/v1/chat/completions';
  static const _model = 'openai/gpt-oss-120b';
  static const _buildApiKey = String.fromEnvironment('GROQ_API_KEY');
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <(String, bool)>[];
  String? _key;
  bool _loading = false;
  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _loadKey() async {
    try {
      final storedKey = await _storage.read(key: 'groq_api_key');
      final key = storedKey?.trim().isNotEmpty == true
          ? storedKey!.trim()
          : _buildApiKey.trim();
      if (storedKey == null && key.isNotEmpty) {
        await _storage.write(key: 'groq_api_key', value: key);
      }
      if (mounted) setState(() => _key = key.isEmpty ? null : key);
    } catch (_) {
      if (mounted) {
        final key = _buildApiKey.trim();
        setState(() => _key = key.isEmpty ? null : key);
      }
    }
  }

  Future<void> _settings() async {
    final controller = TextEditingController(text: _key);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Connect Groq'),
        content: TextField(
          controller: controller,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Groq API key',
            hintText: 'gsk_…',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Save key'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value == null) return;
    if (value.isEmpty) {
      await _storage.delete(key: 'groq_api_key');
      setState(() => _key = null);
      return;
    }
    if (!value.startsWith('gsk_')) {
      _notice('That key does not look like a Groq API key.');
      return;
    }
    await _storage.write(key: 'groq_api_key', value: value);
    if (mounted) setState(() => _key = value);
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _input.text).trim();
    if (text.isEmpty || _loading) return;
    if (_key == null) {
      await _settings();
      if (_key == null) return;
    }
    _input.clear();
    setState(() {
      _messages.add((text, true));
      _loading = true;
    });
    try {
      final history = <Map<String, String>>[
        {
          'role': 'system',
          'content':
              'You are a practical and supportive career assistant. Help with resumes, cover letters, interview preparation and job searches. Be specific. Never invent the user’s experience or credentials.',
        },
        ..._messages.map(
          (m) => {'role': m.$2 ? 'user' : 'assistant', 'content': m.$1},
        ),
      ];
      final response = await http
          .post(
            Uri.parse(_endpoint),
            headers: {
              'Authorization': 'Bearer $_key',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({
              'model': _model,
              'messages': history,
              'temperature': 0.7,
              'max_tokens': 1200,
            }),
          )
          .timeout(const Duration(seconds: 60));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final err = data['error'];
        throw Exception(
          err is Map
              ? err['message']
              : 'Request failed (${response.statusCode}).',
        );
      }
      final answer =
          (((data['choices'] as List).first as Map)['message']
                  as Map)['content']
              as String;
      if (mounted) {
        setState(() => _messages.add((answer.trim(), false)));
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _messages.add((
            'I couldn’t complete that request. ${error.toString().replaceFirst('Exception: ', '')}',
            false,
          )),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scroll.hasClients) {
          _scroll.animateTo(
            _scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _notice(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text('Career assistant'),
      actions: [
        IconButton(
          tooltip: 'API key settings',
          onPressed: _settings,
          icon: Icon(
            _key == null ? Icons.key_outlined : Icons.key,
            color: AppColors.accent,
          ),
        ),
        const SizedBox(width: 8),
      ],
    ),
    body: Column(
      children: [
        Expanded(
          child: _messages.isEmpty
              ? ListView(
                  padding: const EdgeInsets.fromLTRB(20, 25, 20, 20),
                  children: [
                    Text(
                      'Talk through your next step.',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Clear, useful help for the parts of a job search that take time.',
                      style: TextStyle(color: AppColors.muted, height: 1.45),
                    ),
                    if (_key == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 17),
                        child: OutlinedButton.icon(
                          onPressed: _settings,
                          icon: const Icon(Icons.key_outlined),
                          label: const Text('Connect your Groq key'),
                        ),
                      ),
                    const SizedBox(height: 22),
                    ...[
                      ('Resume feedback', 'Help me improve my resume summary.'),
                      (
                        'Interview practice',
                        'Help me prepare for an interview.',
                      ),
                      ('Cover letter', 'Help me write a cover letter.'),
                    ].map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 9),
                        child: Material(
                          color: AppColors.sheet,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => _send(item.$2),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.line),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.chat_bubble_outline,
                                    size: 19,
                                    color: AppColors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.$1,
                                      style: const TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_outward,
                                    size: 16,
                                    color: AppColors.muted,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : ListView(
                  controller: _scroll,
                  padding: const EdgeInsets.all(16),
                  children: [
                    ..._messages.map(
                      (m) => Align(
                        alignment: m.$2
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.sizeOf(context).width * .82,
                          ),
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: m.$2 ? AppColors.accent : AppColors.sheet,
                            borderRadius: BorderRadius.circular(14),
                            border: m.$2
                                ? null
                                : Border.all(color: AppColors.line),
                          ),
                          child: SelectableText(
                            m.$1,
                            style: TextStyle(
                              color: m.$2 ? Colors.white : AppColors.ink,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (_loading)
                      const Padding(
                        padding: EdgeInsets.all(12),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                  ],
                ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
          decoration: const BoxDecoration(
            color: AppColors.paper,
            border: Border(top: BorderSide(color: AppColors.line)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _send(),
                  decoration: const InputDecoration(
                    hintText: 'Ask a career question…',
                  ),
                ),
              ),
              const SizedBox(width: 9),
              IconButton.filled(
                onPressed: _loading ? null : () => _send(),
                icon: const Icon(Icons.arrow_upward_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(50, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
