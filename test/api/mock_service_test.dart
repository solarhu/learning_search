import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/api/mock_service.dart';

void main() {
  group('MockDataService', () {
    test('isDemoQuestion returns true for openclaw', () {
      expect(MockDataService.isDemoQuestion('openclaw'), true);
      expect(MockDataService.isDemoQuestion('openclaw是什么'), true);
      expect(MockDataService.isDemoQuestion('什么是openclaw'), true);
      expect(MockDataService.isDemoQuestion('OPENCLAW'), true);
    });

    test('isDemoQuestion returns false for other questions', () {
      expect(MockDataService.isDemoQuestion('python'), false);
      expect(MockDataService.isDemoQuestion('java'), false);
      expect(MockDataService.isDemoQuestion(''), false);
    });

    test('getSearchResponse returns demo response for demo question', () {
      final response = MockDataService.getSearchResponse('openclaw是什么');
      
      expect(response.answer, contains('OpenClaw'));
      expect(response.keywords.length, greaterThan(0));
      expect(response.keywords, contains('AI辅助编程'));
    });

    test('getSearchResponse returns generic response for other question', () {
      final response = MockDataService.getSearchResponse('什么是人工智能');
      
      expect(response.answer, contains('人工智能'));
      expect(response.keywords.length, greaterThan(0));
      expect(response.keywords, contains('概念定义'));
    });

    test('getExplanation returns predefined explanation', () {
      final explanation = MockDataService.getExplanation('AI辅助编程');
      
      expect(explanation, contains('# AI辅助编程'));
      expect(explanation, contains('定义'));
    });

    test('getExplanation returns generic explanation for unknown keyword', () {
      final explanation = MockDataService.getExplanation('未知关键词');
      
      expect(explanation, contains('# 未知关键词'));
    });

    test('getExplanation with userNote includes personalized content', () {
      final explanation = MockDataService.getExplanation(
        'AI辅助编程',
        userNote: '我关心代码质量',
      );
      
      expect(explanation, contains('您的关注点'));
      expect(explanation, contains('我关心代码质量'));
    });

    test('generateDocument returns demo document for demo question', () {
      final explanations = {
        'AI辅助编程': '这是解释',
        '代码补全': '这是另一个解释',
      };
      
      final result = MockDataService.generateDocument('openclaw是什么', explanations);
      
      expect(result.markdown, contains('# OpenClaw'));
      expect(result.mindmap, contains('- OpenClaw'));
    });

    test('generateDocument returns generic document for other question', () {
      final explanations = {
        '关键词1': '解释1',
      };
      
      final result = MockDataService.generateDocument('其他问题', explanations);
      
      expect(result.markdown, contains('# 其他问题'));
      expect(result.mindmap, contains('- 其他问题'));
    });
  });

  group('MockSearchResponse', () {
    test('creates response with required parameters', () {
      final response = MockSearchResponse(
        answer: 'test answer',
        keywords: ['key1', 'key2'],
      );

      expect(response.answer, 'test answer');
      expect(response.keywords.length, 2);
    });
  });

  group('MockGenerateDocumentResponse', () {
    test('creates response with required parameters', () {
      final response = MockGenerateDocumentResponse(
        markdown: '# Test',
        mindmap: '- Test',
      );

      expect(response.markdown, '# Test');
      expect(response.mindmap, '- Test');
    });
  });
}