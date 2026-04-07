import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'mindmap_view.dart';
import '../api/client.dart';
import '../utils/download_utils_io.dart' if (dart.library.html) '../utils/download_utils_web.dart';

/// 完整学习文档视图
/// 支持长按选中文本添加自定义标注
class DocumentView extends StatefulWidget {
  final String markdown;
  final String mindmap;
  final ApiClient apiClient;
  final Function(String) onCustomSelection;

  const DocumentView({
    super.key,
    required this.markdown,
    required this.mindmap,
    required this.apiClient,
    required this.onCustomSelection,
  });

  @override
  State<DocumentView> createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  bool _isExporting = false;

  Future<void> _export(String format) async {
    setState(() {
      _isExporting = true;
    });
    try {
      final bytes = await widget.apiClient.exportDocument(widget.markdown, format);
      // 触发下载（Web端有效）
      triggerDownload(bytes, 'learning-document.$format');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出 $format 成功，下载已开始 (${bytes.length} bytes)')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  // 长按添加自定义标注
  void _handleLongPress() {
    // 类似搜索模式，弹出让用户输入
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('添加自定义标注'),
        content: const Text('长按文档激活了自定义标注。请输入你想要解释的词语:'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showInputDialog();
            },
            child: const Text('继续'),
          ),
        ],
      ),
    );
  }

  void _showInputDialog() {
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
              final text = textController.text.trim();
              if (text.isNotEmpty) {
                Navigator.pop(context);
                widget.onCustomSelection(text);
              }
            },
            child: const Text('添加解释'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 导出按钮区
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.file_download),
                  label: const Text('导出 Markdown'),
                  onPressed: _isExporting ? null : () => _export('md'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('导出 PDF'),
                  onPressed: _isExporting ? null : () => _export('pdf'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[100],
                    foregroundColor: Colors.red[900],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          MindmapView(mermaidCode: widget.mindmap),
          const SizedBox(height: 24),
          // 包装GestureDetector支持长按添加自定义标注
          GestureDetector(
            onLongPress: _handleLongPress,
            child: MarkdownBody(
              data: widget.markdown,
              selectable: true,
              checkboxBuilder: (value) {
                return Checkbox(value: value, onChanged: null);
              },
            ),
          ),
        ],
      ),
    );
  }
}
