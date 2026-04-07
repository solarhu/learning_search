import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/keyword.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  /// 搜索问题，获取带标注的答案
  Future<SearchResponse> search(String question) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/search'),
      body: jsonEncode({'question': question}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SearchResponse(
        answer: data['answer'],
        keywords: List<String>.from(data['keywords']),
      );
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }

  /// 解释自动标注的关键词
  Future<String> explain(String keyword) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/explain'),
      body: jsonEncode({
        'keyword': keyword,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['explanation'];
    } else {
      throw Exception('Explain failed: ${response.statusCode}');
    }
  }

  /// 解释用户自定义关键词
  Future<String> explainCustom(
    String keyword,
    String userNote,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/explain-custom'),
      body: jsonEncode({
        'keyword': keyword,
        'user_note': userNote,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['explanation'];
    } else {
      throw Exception('Explain custom failed: ${response.statusCode}');
    }
  }

  /// 生成学习文档
  Future<GenerateDocumentResponse> generateDocument(
    String question,
    List<Keyword> history,
  ) async {
    // Convert to Map<String, String> explanations
    final explanations = {
      for (var kw in history.where((k) => k.explanation != null))
        kw.text: kw.explanation!
    };
    final response = await http.post(
      Uri.parse('$baseUrl/api/generate-document'),
      body: jsonEncode({
        'question': question,
        'explanations': explanations,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GenerateDocumentResponse(
        markdown: data['markdown'],
        mindmap: data['mindmap'],
      );
    } else {
      throw Exception('Generate document failed: ${response.statusCode}');
    }
  }

  /// 导出文档
  Future<List<int>> exportDocument(
    String markdown,
    String format,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/export'),
      body: jsonEncode({
        'markdown': markdown,
        'format': format,
      }),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception('Export failed: ${response.statusCode}');
    }
  }
}

class SearchResponse {
  final String answer;
  final List<String> keywords;

  SearchResponse({required this.answer, required this.keywords});
}

class ExplainCustomResponse {
  final String explanation;
  final String? updatedDocument;

  ExplainCustomResponse({
    required this.explanation,
    this.updatedDocument,
  });
}

class GenerateDocumentResponse {
  final String markdown;
  final String mindmap;

  GenerateDocumentResponse({
    required this.markdown,
    required this.mindmap,
  });
}

class ExportResponse {
  final String? downloadUrl;
  final String? content;

  ExportResponse({
    this.downloadUrl,
    this.content,
  });
}
