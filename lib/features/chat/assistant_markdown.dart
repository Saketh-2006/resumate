import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../theme/app_theme.dart';

/// Renders an assistant response as GitHub-flavored Markdown.
///
/// The package's intrinsic table layout keeps wide tables inside their own
/// horizontal scroll area, so they can be read without widening the chat
/// bubble or overflowing the conversation.
class AssistantMarkdown extends StatelessWidget {
  const AssistantMarkdown({super.key, required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final base = Theme.of(context).textTheme.bodyMedium ?? const TextStyle();
    final style = MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      p: base.copyWith(color: colors.ink, height: 1.45, fontSize: 14),
      h1: base.copyWith(
        color: colors.ink,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
      h2: base.copyWith(
        color: colors.ink,
        fontSize: 19,
        fontWeight: FontWeight.w700,
      ),
      h3: base.copyWith(
        color: colors.ink,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
      h4: base.copyWith(
        color: colors.ink,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      h5: base.copyWith(
        color: colors.ink,
        fontSize: 14,
        fontWeight: FontWeight.w700,
      ),
      h6: base.copyWith(
        color: colors.ink,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
      a: base.copyWith(
        color: colors.accent,
        decoration: TextDecoration.underline,
      ),
      blockquote: base.copyWith(
        color: colors.muted,
        fontStyle: FontStyle.italic,
      ),
      blockquotePadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      blockquoteDecoration: BoxDecoration(
        border: Border(left: BorderSide(color: colors.accent, width: 3)),
      ),
      code: TextStyle(
        fontFamily: 'monospace',
        fontSize: 12,
        color: colors.ink,
        backgroundColor: colors.accentSoft,
      ),
      codeblockPadding: const EdgeInsets.all(10),
      codeblockDecoration: BoxDecoration(
        color: colors.accentSoft,
        borderRadius: BorderRadius.circular(8),
      ),
      tableHead: base.copyWith(color: colors.ink, fontWeight: FontWeight.w700),
      tableBody: base.copyWith(color: colors.ink, height: 1.35),
      tableHeadAlign: TextAlign.start,
      tableBorder: TableBorder.all(color: colors.line, width: 1),
      tableColumnWidth: const IntrinsicColumnWidth(),
      tableCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      tableHeadCellsPadding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 8,
      ),
      tableCellsDecoration: BoxDecoration(color: colors.sheet),
      tableHeadCellsDecoration: BoxDecoration(color: colors.accentSoft),
      tableVerticalAlignment: TableCellVerticalAlignment.middle,
      tableScrollbarThumbVisibility: false,
      blockSpacing: 10,
      listIndent: 20,
    );

    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: style,
      onTapLink: (text, href, title) {
        final uri = Uri.tryParse(href ?? '');
        if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
          unawaited(launchUrl(uri, mode: LaunchMode.externalApplication));
        }
      },
    );
  }
}
