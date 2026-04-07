// 跨平台下载触发工具
import 'package:flutter/foundation.dart';

void triggerDownload(List<int> bytes, String filename) {
  if (kIsWeb) {
    // ignore: avoid_web_libraries_in_flutter
    import 'dart:html' as html;
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', filename)
      ..click();
    html.Url.revokeObjectUrl(url);
  }
  // 移动端后续实现
}
