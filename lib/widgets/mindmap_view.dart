import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

/// Mermaid 思维导图展示组件
/// 因为 Flutter 直接渲染 Mermaid 需要 webview，这里用 Markdown 代码块展示
/// 实际在 Web 可以用 mermaid.js，在鸿蒙可以用 webview 渲染
class MindmapView extends StatelessWidget {
  final String mermaidCode;

  const MindmapView({
    super.key,
    required this.mermaidCode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '知识框架',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          MarkdownBody(
            data: '```mermaid\n$mermaidCode\n```',
            selectable: true,
          ),
        ],
      ),
    );
  }
}
