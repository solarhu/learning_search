import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/api/client.dart';
import 'package:learning_search/models/keyword.dart';

void main() {
  group('ApiClient', () {
    test('creates client with baseUrl', () {
      final client = ApiClient(baseUrl: 'http://localhost:8081');
      
      expect(client.baseUrl, 'http://localhost:8081');
      expect(client.useMock, false);
    });

    test('creates client with mock mode', () {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      expect(client.baseUrl, '');
      expect(client.useMock, true);
    });

    test('isMockMode returns correct value', () {
      final mockClient = ApiClient(baseUrl: '', useMock: true);
      final realClient = ApiClient(baseUrl: 'http://localhost:8081');
      
      expect(mockClient.isMockMode(), true);
      expect(realClient.isMockMode(), false);
    });

    test('search returns mock response in mock mode', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      final response = await client.search('openclaw是什么');
      
      expect(response.answer, contains('OpenClaw'));
      expect(response.keywords.length, greaterThan(0));
    });

    test('explain returns mock explanation in mock mode', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      final explanation = await client.explain('AI辅助编程');
      
      expect(explanation, contains('# AI辅助编程'));
    });

    test('explainCustom returns mock explanation with userNote', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      final explanation = await client.explainCustom('AI辅助编程', '我的关注点');
      
      expect(explanation, contains('您的关注点'));
    });

    test('generateDocument returns mock document in mock mode', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      final keywords = [
        Keyword(text: 'keyword1', explanation: 'explanation1'),
        Keyword(text: 'keyword2', explanation: 'explanation2'),
      ];
      
      final response = await client.generateDocument('test question', keywords);
      
      expect(response.markdown, contains('#'));
      expect(response.mindmap, contains('-'));
    });

    test('exportDocument returns encoded markdown for md format', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      final bytes = await client.exportDocument('# Test Document', 'md');
      
      expect(bytes.length, greaterThan(0));
    });

    test('exportDocument throws for pdf format in mock mode', () async {
      final client = ApiClient(baseUrl: '', useMock: true);
      
      expect(
        () => client.exportDocument('# Test', 'pdf'),
        throwsException,
      );
    });
  });

  group('SearchResponse', () {
    test('creates response with required parameters', () {
      final response = SearchResponse(
        answer: 'test answer',
        keywords: ['key1', 'key2'],
      );

      expect(response.answer, 'test answer');
      expect(response.keywords.length, 2);
    });
  });

  group('GenerateDocumentResponse', () {
    test('creates response with required parameters', () {
      final response = GenerateDocumentResponse(
        markdown: '# Test',
        mindmap: '- Test',
      );

      expect(response.markdown, '# Test');
      expect(response.mindmap, '- Test');
    });
  });
}