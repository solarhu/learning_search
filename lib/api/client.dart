import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/keyword.dart';
import 'mock_service.dart';
import 'api_config.dart';

class ApiClient {
  final String baseUrl;
  final bool useMock;

  ApiClient({required this.baseUrl, this.useMock = false});

  static Future<ApiClient> create() async {
    final baseUrl = await ApiConfig.getBaseUrl();
    final useMock = baseUrl.isEmpty;
    print('=== ApiClient.create: baseUrl="$baseUrl", useMock=$useMock ===');
    return ApiClient(baseUrl: baseUrl, useMock: useMock);
  }

  Future<SearchResponse> search(String question) async {
    print('=== search called: useMock=$useMock, question="$question" ===');
    if (useMock) {
      print('=== Using Mock Data ===');
      final mockResponse = MockDataService.getSearchResponse(question);
      return SearchResponse(
        answer: mockResponse.answer,
        keywords: mockResponse.keywords,
      );
    }

    print('=== Calling API: $baseUrl/api/search ===');
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

  Future<String> explain(String keyword) async {
    if (useMock) {
      return MockDataService.getExplanation(keyword);
    }

    final response = await http.post(
      Uri.parse('$baseUrl/api/explain'),
      body: jsonEncode({'keyword': keyword}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['explanation'];
    } else {
      throw Exception('Explain failed: ${response.statusCode}');
    }
  }

  Future<String> explainCustom(String keyword, String userNote) async {
    if (useMock) {
      return MockDataService.getExplanation(keyword, userNote: userNote);
    }

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

  Future<GenerateDocumentResponse> generateDocument(
    String question,
    List<Keyword> history,
  ) async {
    final explanations = {
      for (var kw in history.where((k) => k.explanation != null))
        kw.text: kw.explanation!
    };

    if (useMock) {
      final mockResponse = MockDataService.generateDocument(question, explanations);
      return GenerateDocumentResponse(
        markdown: mockResponse.markdown,
        mindmap: mockResponse.mindmap,
      );
    }

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

  Future<List<int>> exportDocument(String markdown, String format) async {
    if (useMock) {
      if (format == 'md') {
        return utf8.encode(markdown);
      }
      throw Exception('PDF export requires real backend API');
    }

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

  bool isMockMode() => useMock;
}

class SearchResponse {
  final String answer;
  final List<String> keywords;

  SearchResponse({required this.answer, required this.keywords});
}

class GenerateDocumentResponse {
  final String markdown;
  final String mindmap;

  GenerateDocumentResponse({required this.markdown, required this.mindmap});
}