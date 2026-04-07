import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'mindmap_view.dart';
import '../api/client.dart';
import '../utils/download_utils_io.dart' if (dart.library.html) '../utils/download_utils_web.dart';

/// 完整学习文档视图
class DocumentView extends StatefulWidget {
  final String markdown;
  final String mindmap;
  final ApiClient apiClient;

  const DocumentView({
    super.key,
    required this.markdown,
    required this.mindmap,
    required this.apiClient,
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
          MarkdownBody(
            data: widget.markdown,
            selectable: true,
            checkboxBuilder: (value) {
              return Checkbox(value: value, onChanged: null);
            },
          ),
        ],
      ),
    );
  }
}
