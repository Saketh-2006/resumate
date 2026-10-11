import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:resumate_ai/features/chat/assistant_markdown.dart';
import 'package:resumate_ai/theme/app_theme.dart';

void main() {
  testWidgets(
    'renders Markdown and multiple responsive tables without overflow',
    (tester) async {
      tester.view.physicalSize = const Size(360, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light,
          home: Scaffold(
            body: Center(
              child: Container(
                width: 270,
                padding: const EdgeInsets.all(12),
                child: const AssistantMarkdown(
                  data: '''
# Career plan

Use **bold**, *italic*, `inline code`, and [a link](https://example.com).

> A useful quote.

1. First step
2. Second step

- One option
- Another option

| Skill | Level | Notes |
| :--- | :---: | ---: |
| Flutter | Strong | A long note that should wrap or remain reachable by horizontal scrolling. |
| Dart | Growing | Builds apps |

```dart
final answer = 42;
```

| A | B |
| --- | --- |
| one | two |
''',
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Career plan'), findsOneWidget);
      expect(find.text('Flutter'), findsOneWidget);
      expect(find.byType(Table), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('handles incomplete Markdown syntax without crashing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: AssistantMarkdown(
            data: '## unfinished **bold\n\n| a | b |\n| -- |\n| x |',
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
