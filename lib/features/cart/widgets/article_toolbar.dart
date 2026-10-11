import 'package:flutter/material.dart';

/// Uses the same Markdown format as the website's article editor.
class ArticleToolbar extends StatelessWidget {
  const ArticleToolbar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.enabled,
  });
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool enabled;

  void _format(String before, [String after = '']) {
    final text = controller.text;
    final selection = controller.selection;
    final start = selection.isValid ? selection.start : text.length;
    final end = selection.isValid ? selection.end : text.length;
    final value = text.replaceRange(
      start,
      end,
      '$before${text.substring(start, end)}$after',
    );
    if (value.length > 40000) return;
    controller.value = TextEditingValue(
      text: value,
      selection: TextSelection(
        baseOffset: start + before.length,
        extentOffset: end + before.length,
      ),
    );
    focusNode.requestFocus();
  }

  @override
  Widget build(BuildContext context) => Wrap(
    children: [
      for (final tool in <(String, IconData, String, String)>[
        ('Heading', Icons.title, '## ', ''),
        ('Bold', Icons.format_bold, '**', '**'),
        ('Italic', Icons.format_italic, '*', '*'),
        ('Strikethrough', Icons.strikethrough_s, '~~', '~~'),
        ('Bullet list', Icons.format_list_bulleted, '- ', ''),
        ('Numbered list', Icons.format_list_numbered, '1. ', ''),
        ('Link', Icons.link, '[', '](https://)'),
      ])
        IconButton(
          tooltip: tool.$1,
          icon: Icon(tool.$2),
          onPressed: enabled ? () => _format(tool.$3, tool.$4) : null,
        ),
    ],
  );
}
