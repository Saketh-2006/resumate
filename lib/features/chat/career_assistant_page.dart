import 'package:flutter/material.dart';
import '../../api_service.dart';
import '../../theme/app_theme.dart';

class CareerAssistantPage extends StatefulWidget {
  const CareerAssistantPage({super.key});
  @override
  State<CareerAssistantPage> createState() => _CareerAssistantPageState();
}

class _CareerAssistantPageState extends State<CareerAssistantPage> {
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <(String, bool)>[];
  bool _loading = false;
  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? suggested]) async {
    final text = (suggested ?? _input.text).trim();
    if (text.isEmpty || _loading) return;
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
      final answer = await ApiService.chat(history, temperature: 0.7);
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

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Career assistant')),
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
                            color: context.colors.ink,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Clear, useful help for the parts of a job search that take time.',
                      style: TextStyle(color: context.colors.muted, height: 1.45),
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
                          color: context.colors.sheet,
                          borderRadius: BorderRadius.circular(10),
                          child: InkWell(
                            onTap: () => _send(item.$2),
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                border: Border.all(color: context.colors.line),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.chat_bubble_outline,
                                    size: 19,
                                    color: context.colors.accent,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      item.$1,
                                      style: TextStyle(
                                        color: context.colors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_outward,
                                    size: 16,
                                    color: context.colors.muted,
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
                            color: m.$2 ? context.colors.accent : context.colors.sheet,
                            borderRadius: BorderRadius.circular(14),
                            border: m.$2
                                ? null
                                : Border.all(color: context.colors.line),
                          ),
                          child: SelectableText(
                            m.$1,
                            style: TextStyle(
                              color: m.$2 ? Colors.white : context.colors.ink,
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
          decoration: BoxDecoration(
            color: context.colors.paper,
            border: Border(top: BorderSide(color: context.colors.line)),
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
                  backgroundColor: context.colors.accent,
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
