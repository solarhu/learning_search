import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef KeywordTapCallback = void Function(String keyword);
typedef CustomSelectionCallback = void Function(String selectedText);

/// 带可点击关键词的文本组件
/// 支持自动关键词点击 + 长按选中文本自定义标注
class KeywordText extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // 使用GestureDetector检测长按，支持用户自定义选中文本
    return GestureDetector(
      onLongPress: () => _handleLongPress(context),
      child: RichText(
        text: TextSpan(children: _parseText()),
      ),
    );
  }

  List<TextSpan> _parseText() {
    List<TextSpan> spans = [];
    String current = text;

    // 关键词已经是列表形式，直接遍历分词高亮
    // 我们采用简单策略：匹配整个关键词，支持多关键词
    // 为简化实现，这里不做复杂分词，直接使用原始文本，自动关键词由API返回
    // 自动关键词已经是独立列表，前端高亮点击
    // 这里简化：原始文本中自动关键词会被识别并高亮
    // 实际上，我们已经拿到关键词列表，直接构建高亮
    // 这里采用更简单的方式：整段文字，自动关键词高亮
    // 因为原始答案中不一定有下划线，所以我们直接按关键词替换高亮
    // 这种方式更符合我们当前设计（LLM直接返回关键词列表，不要求原文本带标记）

    // 按顺序处理，找出所有关键词位置
    // 这个简化版本直接把关键词识别出来并高亮
    // 这里用一个简单实现：遍历关键词替换
    String remaining = text;
    for (final keyword in keywords) {
      // 简化处理，不处理重叠
      if (remaining.contains(keyword)) {
        final index = remaining.indexOf(keyword);
        if (index > 0) {
          spans.add(TextSpan(
            text: remaining.substring(0, index),
            style: const TextStyle(color: Colors.black87),
          ));
        }
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
        remaining = remaining.substring(index + keyword.length);
      }
    }
    if (remaining.isNotEmpty) {
      spans.add(TextSpan(
        text: remaining,
        style: const TextStyle(color: Colors.black87),
      ));
    }

    return spans;
  }

  void _handleLongPress(BuildContext context) {
    // 长按弹出简单对话框让用户输入要标注的文本
    // 用户可以确认或修改选中的文本
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加自定义标注'),
        content: const Text('长按选中了整片文本。请输入你想要自定义标注的词语:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // 这里简化：让用户手动输入要标注的文本
              // 完美文本选择需要更复杂的处理，MVP先用简化方案
              Navigator.pop(context);
              _showInputDialog(context);
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog(BuildContext context) {
    final TextEditingController textController = TextEditingController();
    final TextEditingController noteController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('自定义关键词'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: textController,
              decoration: const InputDecoration(
                labelText: '要解释的词语',
                hintText: '输入你想深入了解的词语',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: noteController,
              decoration: const InputDecoration(
                labelText: '标注说明（可选）',
                hintText: '比如："我想了解它在React中的应用"',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              final selectedText = textController.text.trim();
              if (selectedText.isNotEmpty) {
                Navigator.pop(context);
                onCustomSelection(selectedText);
              }
            },
            child: const Text('添加解释'),
          ),
        ],
      ),
    );
  }
}
