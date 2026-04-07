import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef KeywordTapCallback = void Function(String keyword);

/// 带可点击关键词的文本组件
class KeywordText extends StatelessWidget {
  final String text;
  final List<String> keywords;
  final KeywordTapCallback onKeywordTap;

  const KeywordText({
    super.key,
    required this.text,
    required this.keywords,
    required this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    final spans = _parseText();
    return RichText(
      text: TextSpan(children: spans),
    );
  }

  List<TextSpan> _parseText() {
    List<TextSpan> spans = [];
    String current = text;

    // 按 _keyword_ 格式分割
    while (current.isNotEmpty) {
      final start = current.indexOf('_');
      if (start == -1) {
        spans.add(TextSpan(text: current, style: const TextStyle(color: Colors.black)));
        break;
      }

      // 添加前面的普通文本
      if (start > 0) {
        spans.add(TextSpan(text: current.substring(0, start), style: const TextStyle(color: Colors.black)));
      }

      final end = current.indexOf('_', start + 1);
      if (end == -1) {
        spans.add(TextSpan(text: current.substring(start), style: const TextStyle(color: Colors.black)));
        break;
      }

      final keyword = current.substring(start + 1, end);
      spans.add(TextSpan(
        text: keyword,
        style: TextStyle(
          color: Colors.blue[700],
          decoration: TextDecoration.underline,
          fontWeight: FontWeight.bold,
        ),
        recognizer: TapGestureRecognizer()
          ..onTap = () {
            onKeywordTap(keyword);
          },
      ));

      current = current.substring(end + 1);
    }

    return spans;
  }
}
