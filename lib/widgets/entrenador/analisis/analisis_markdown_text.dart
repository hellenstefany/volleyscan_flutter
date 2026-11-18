import 'package:flutter/material.dart';

import 'analisis_theme.dart';

/// Markdown mínimo (`.ai-bubble` en `Analisis.css`): **negrita**, `## título`, `### subtítulo` y párrafos.
class AnalisisMarkdownText extends StatelessWidget {
  final String text;

  const AnalisisMarkdownText(this.text, {super.key});

  static const _base = TextStyle(
    fontSize: 14.9,
    height: 1.75,
    color: AnalisisTheme.text,
  );

  List<InlineSpan> _inline(String line, TextStyle style) {
    final spans = <InlineSpan>[];
    final re = RegExp(r'\*\*(.*?)\*\*');
    var last = 0;
    for (final m in re.allMatches(line)) {
      if (m.start > last) {
        spans.add(TextSpan(text: line.substring(last, m.start), style: style));
      }
      spans.add(
        TextSpan(
          text: m.group(1),
          style: style.copyWith(
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      );
      last = m.end;
    }
    if (last < line.length) {
      spans.add(TextSpan(text: line.substring(last), style: style));
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final paragraphs = text.split(RegExp(r'\n{2,}'));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var p = 0; p < paragraphs.length; p++)
          Padding(
            padding: EdgeInsets.only(top: p == 0 ? 0 : 14),
            child: Text.rich(
              TextSpan(children: _paragraph(paragraphs[p])),
            ),
          ),
      ],
    );
  }

  List<InlineSpan> _paragraph(String para) {
    final lines = para.split('\n');
    final spans = <InlineSpan>[];
    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];
      TextStyle style = _base;
      String content = line;

      if (line.startsWith('### ')) {
        content = line.substring(4);
        style = _base.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: AnalisisTheme.text,
        );
      } else if (line.startsWith('## ')) {
        content = line.substring(3);
        style = _base.copyWith(
          fontSize: 16.0,
          fontWeight: FontWeight.w700,
          color: AnalisisTheme.text,
        );
      }

      spans.addAll(_inline(content, style));
      if (i < lines.length - 1) spans.add(const TextSpan(text: '\n'));
    }
    return spans;
  }
}
