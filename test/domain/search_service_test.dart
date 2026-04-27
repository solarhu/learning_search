import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/api/client.dart';
import 'package:learning_search/api/mock_service.dart';
import 'package:learning_search/domain/search_service.dart';
import 'package:learning_search/models/keyword.dart';

void main() {
  group('SearchService', () {
    late ApiClient mockApiClient;
    late SearchService searchService;

    setUp(() {
      mockApiClient = ApiClient(baseUrl: '', useMock: true);
      searchService = SearchService(apiClient: mockApiClient);
    });

    test('searchQuestion returns answer and sets keywords', () async {
      final answer = await searchService.searchQuestion('openclaw是什么');
      
      expect(answer, contains('OpenClaw'));
      expect(searchService.currentQuestion, 'openclaw是什么');
      expect(searchService.currentAnswer, contains('OpenClaw'));
      expect(searchService.explainedKeywords.length, greaterThan(0));
    });

    test('searchQuestion clears previous keywords', () async {
      await searchService.searchQuestion('openclaw是什么');
      expect(searchService.explainedKeywords.length, greaterThan(0));
      
      await searchService.searchQuestion('python是什么');
      expect(searchService.explainedKeywords.length, greaterThan(0));
      expect(searchService.explainedKeywords.any((k) => k.text == 'AI辅助编程'), false);
    });

    test('explainKeyword updates existing keyword', () async {
      await searchService.searchQuestion('openclaw是什么');
      final keyword = searchService.explainedKeywords.first;
      
      final explanation = await searchService.explainKeyword(keyword);
      
      expect(explanation, contains('#'));
      final updatedKeyword = searchService.explainedKeywords.firstWhere(
        (k) => k.text == keyword.text,
      );
      expect(updatedKeyword.explanation, isNotNull);
    });

    test('explainKeyword adds new keyword if not exists', () async {
      final keyword = Keyword(text: '新关键词');
      
      final explanation = await searchService.explainKeyword(keyword);
      
      expect(explanation, contains('# 新关键词'));
      expect(
        searchService.explainedKeywords.any((k) => k.text == '新关键词'),
        true,
      );
    });

    test('explainCustomKeyword adds custom keyword', () async {
      final explanation = await searchService.explainCustomKeyword(
        '自定义关键词',
        '我的标注',
      );
      
      expect(explanation, contains('您的关注点'));
      expect(
        searchService.explainedKeywords.any((k) => k.text == '自定义关键词'),
        true,
      );
      final customKeyword = searchService.explainedKeywords.firstWhere(
        (k) => k.text == '自定义关键词',
      );
      expect(customKeyword.isCustom, true);
    });

    test('generateDocument throws without question', () async {
      searchService.currentQuestion = null;
      
      expect(
        () => searchService.generateDocument(),
        throwsException,
      );
    });

    test('generateDocument returns document with question', () async {
      await searchService.searchQuestion('openclaw是什么');
      final keyword = searchService.explainedKeywords.first;
      await searchService.explainKeyword(keyword);
      
      final result = await searchService.generateDocument();
      
      expect(result.markdown, contains('#'));
      expect(result.mindmap, contains('-'));
    });
  });

  group('GenerateDocumentResult', () {
    test('creates result with required parameters', () {
      final result = GenerateDocumentResult(
        markdown: '# Test',
        mindmap: '- Test',
      );

      expect(result.markdown, '# Test');
      expect(result.mindmap, '- Test');
    });
  });
}