import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'stub_html.dart' as html;

typedef KeywordTapCallback = void Function(String keyword);
typedef CustomSelectionCallback = void Function(String selectedText);

class KeywordText extends StatefulWidget {
  final String text;
  final List<String> keywords;
  final KeywordTapCallback onKeywordTap;
  final CustomSelectionCallback onCustomSelection;

  const KeywordText({
    super.key,
    required this.text,
    required this.keywords,
    required this.onKeywordTap,
    required this.onCustomSelection,
  });

  @override
  State<KeywordText> createState() => _KeywordTextState();
}

class _KeywordTextState extends State<KeywordText> {
  @override
  Widget build(BuildContext context) {
    if (!kIsWeb) {
      return RichText(text: _buildTextSpan());
    }

    return SelectableText.rich(
      _buildTextSpan(),
      style: const TextStyle(fontSize: 14, color: Colors.black87),
    );
  }

  TextSpan _buildTextSpan() {
    List<TextSpan> spans = [];
    String remaining = widget.text;

    for (final keyword in widget.keywords) {
      if (remaining.contains(keyword)) {
        final index = remaining.indexOf(keyword);
        if (index > 0) {
          spans.add(TextSpan(
            text: remaining.substring(0, index),
          ));
        }
        spans.add(TextSpan(
          text: keyword,
          style: TextStyle(
            color: Colors.blue[700],
            decoration: TextDecoration.underline,
            fontWeight: FontWeight.w500,
          ),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              widget.onKeywordTap(keyword);
            },
        ));
        remaining = remaining.substring(index + keyword.length);
      }
    }

    if (remaining.isNotEmpty) {
      spans.add(TextSpan(text: remaining));
    }

    return TextSpan(children: spans);
  }

  static String? getSelectedText() {
    if (!kIsWeb) return null;

    try {
      final selection = html.window.getSelection();
      if (selection != null && selection.toString().trim().length > 0) {
        return selection.toString().trim();
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}