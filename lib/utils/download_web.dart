// 下载触发 - Web 实现
// ignore: avoid_web_libraries_in_flutter
import 'dart:html';

void triggerDownload(List<int> bytes, String filename) {
  final blob = Blob([bytes]);
  final url = Url.createObjectUrlFromBlob(blob);
  final anchor = AnchorElement(href: url)
    ..setAttribute('download', filename)
    ..click();
  Url.revokeObjectUrl(url);
}
