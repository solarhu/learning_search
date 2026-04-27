import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/models/keyword.dart';

void main() {
  group('Keyword', () {
    test('creates keyword with required parameters', () {
      final keyword = Keyword(text: 'test keyword');
      
      expect(keyword.text, 'test keyword');
      expect(keyword.explanation, null);
      expect(keyword.isCustom, false);
      expect(keyword.explainedAt, isNotNull);
    });

    test('creates keyword with all parameters', () {
      final explainedAt = DateTime(2024, 1, 1);
      final keyword = Keyword(
        text: 'test keyword',
        explanation: 'test explanation',
        isCustom: true,
        explainedAt: explainedAt,
      );

      expect(keyword.text, 'test keyword');
      expect(keyword.explanation, 'test explanation');
      expect(keyword.isCustom, true);
      expect(keyword.explainedAt, explainedAt);
    });

    test('copyWith preserves original values when not provided', () {
      final keyword = Keyword(
        text: 'original',
        explanation: 'original explanation',
        isCustom: true,
      );

      final copied = keyword.copyWith();

      expect(copied.text, 'original');
      expect(copied.explanation, 'original explanation');
      expect(copied.isCustom, true);
    });

    test('copyWith updates provided values', () {
      final keyword = Keyword(
        text: 'original',
        explanation: 'original explanation',
        isCustom: false,
      );

      final copied = keyword.copyWith(
        text: 'new',
        explanation: 'new explanation',
        isCustom: true,
      );

      expect(copied.text, 'new');
      expect(copied.explanation, 'new explanation');
      expect(copied.isCustom, true);
    });

    test('toJson returns correct map', () {
      final keyword = Keyword(
        text: 'test',
        explanation: 'explanation',
        isCustom: true,
      );

      final json = keyword.toJson();

      expect(json['keyword'], 'test');
      expect(json['explanation'], 'explanation');
      expect(json['is_custom'], true);
    });

    test('toJson with null explanation', () {
      final keyword = Keyword(text: 'test');

      final json = keyword.toJson();

      expect(json['keyword'], 'test');
      expect(json['explanation'], null);
      expect(json['is_custom'], false);
    });
  });
}