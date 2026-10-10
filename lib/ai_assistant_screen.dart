import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import 'api_service.dart';
import 'resume_data.dart';

class AiAssistantScreen extends StatefulWidget {
  final ResumeData? resumeData;

  const AiAssistantScreen({super.key, this.resumeData});

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final _controller = TextEditingController();
  final _messages = <({String text, bool fromUser})>[];
  bool _sending = false;

  static const prompts = [
    'How can I improve a project description?',
    'What makes a resume easier to scan?',
    'How should I describe a skill I already have?',
    'What should I include in achievements?',
  ];

  Future<void> _send([String? prompt]) async {
    final message = (prompt ?? _controller.text).trim();
    if (message.isEmpty || _sending) return;
    setState(() {
      _messages.add((text: message, fromUser: true));
      _controller.clear();
      _sending = true;
    });
    try {
      final resumeContext = widget.resumeData?.toJson();
      resumeContext?.remove('profilePhotoData');
      resumeContext?.remove('profilePhotoPath');
      resumeContext?.remove('id');
      resumeContext?.remove('updatedAt');
      resumeContext?.remove('email');
      resumeContext?.remove('phone');
      resumeContext?.remove('location');
      resumeContext?.remove('linkedin');
      resumeContext?.remove('github');
      resumeContext?.remove('portfolio');
      resumeContext?.remove('leetcode');
      final context = resumeContext == null ? '' : jsonEncode(resumeContext);
      final response = await ApiService.askAssistant(
        message: message,
        resumeContext: context,
      );
      if (!mounted) return;
      setState(() {
        _messages.add((
          text: response['answer'] as String? ?? 'No answer was returned.',
          fromUser: false,
        ));
      });
    } catch (error) {
      if (!mounted) return;
      final errorMessage = error is TimeoutException
          ? 'The local AI is taking longer than expected to respond. The first reply can be slow while the model loads. Wait a moment and try again.'
          : 'Could not reach the AI service. Make sure both the backend and Ollama are running, then try again. Details: $error';
      setState(() {
        _messages.add((
          text: errorMessage,
          fromUser: false,
        ));
      });
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('ResuMate AI Assistant')),
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Column(
                children: [
                  Expanded(
                    child: _messages.isEmpty
                        ? ListView(
                            padding: const EdgeInsets.all(20),
                            children: [
                              Text(
                                'Get practical resume help',
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'ResuMate uses only the facts you provide. If something important is missing, it should ask instead of making it up.',
                              ),
                              if (widget.resumeData != null) ...[
                                const SizedBox(height: 10),
                                const Text(
                                  'This conversation sends the resume details shown in the app to your configured backend for an answer.',
                                ),
                              ],
                              const SizedBox(height: 20),
                              for (final prompt in prompts)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: OutlinedButton(
                                    onPressed: () => _send(prompt),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(prompt),
                                    ),
                                  ),
                                ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _messages.length,
                            itemBuilder: (context, index) {
                              final item = _messages[index];
                              return Align(
                                alignment: item.fromUser
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Container(
                                  constraints: const BoxConstraints(maxWidth: 600),
                                  margin: const EdgeInsets.only(bottom: 12),
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: item.fromUser
                                        ? Theme.of(context).colorScheme.primaryContainer
                                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: SelectableText(item.text),
                                ),
                              );
                            },
                          ),
                  ),
                  if (_sending)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: LinearProgressIndicator(),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            minLines: 1,
                            maxLines: 4,
                            textInputAction: TextInputAction.send,
                            onSubmitted: (_) => _send(),
                            decoration: const InputDecoration(
                              hintText: 'Ask a resume question…',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton.filled(
                          tooltip: 'Send',
                          onPressed: _sending ? null : () => _send(),
                          icon: const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
}
