import 'dart:async';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' if (dart.library.io) 'stub_html.dart' as html;
import 'dart:js_util' if (dart.library.io) 'stub_js_util.dart' as js_util;

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

    return Listener(
      onPointerUp: (event) {
        _captureSelection();
      },
      child: SelectableText.rich(
        _buildTextSpan(),
        style: const TextStyle(fontSize: 14, color: Colors.black87),
      ),
    );
  }

  void _captureSelection() {
    Future.delayed(const Duration(milliseconds: 100), () {
      final text = getSelectedText();
      if (text != null && text.isNotEmpty) {
        widget.onCustomSelection(text);
      }
    });
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
      if (selection != null) {
        final text = (js_util.callMethod(selection, 'toString', []) as String).trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}