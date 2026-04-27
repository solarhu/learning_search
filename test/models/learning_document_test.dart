import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/models/keyword.dart';
import 'package:learning_search/models/learning_document.dart';

void main() {
  group('LearningDocument', () {
    test('creates document with required parameters', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 1, 2);
      final keywords = [Keyword(text: 'keyword1'), Keyword(text: 'keyword2')];
      
      final document = LearningDocument(
        id: 'doc-1',
        question: 'test question',
        markdown: '# Test Document',
        mindmap: '- Test\n  - Item',
        keywords: keywords,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      expect(document.id, 'doc-1');
      expect(document.question, 'test question');
      expect(document.markdown, '# Test Document');
      expect(document.mindmap, '- Test\n  - Item');
      expect(document.keywords.length, 2);
      expect(document.createdAt, createdAt);
      expect(document.updatedAt, updatedAt);
    });

    test('copyWith preserves original values when not provided', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 1, 2);
      final keywords = [Keyword(text: 'keyword1')];
      
      final document = LearningDocument(
        id: 'doc-1',
        question: 'question',
        markdown: 'markdown',
        mindmap: 'mindmap',
        keywords: keywords,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final copied = document.copyWith();

      expect(copied.id, 'doc-1');
      expect(copied.question, 'question');
      expect(copied.markdown, 'markdown');
      expect(copied.mindmap, 'mindmap');
      expect(copied.keywords.length, 1);
      expect(copied.createdAt, createdAt);
    });

    test('copyWith updates provided values', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 1, 2);
      final newUpdatedAt = DateTime(2024, 1, 3);
      final keywords = [Keyword(text: 'keyword1')];
      final newKeywords = [Keyword(text: 'new')];
      
      final document = LearningDocument(
        id: 'doc-1',
        question: 'question',
        markdown: 'markdown',
        mindmap: 'mindmap',
        keywords: keywords,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final copied = document.copyWith(
        id: 'doc-2',
        question: 'new question',
        markdown: 'new markdown',
        mindmap: 'new mindmap',
        keywords: newKeywords,
        updatedAt: newUpdatedAt,
      );

      expect(copied.id, 'doc-2');
      expect(copied.question, 'new question');
      expect(copied.markdown, 'new markdown');
      expect(copied.mindmap, 'new mindmap');
      expect(copied.keywords.length, 1);
      expect(copied.keywords.first.text, 'new');
      expect(copied.updatedAt, newUpdatedAt);
    });

    test('copyWith uses current time for updatedAt if not provided', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 1, 2);
      
      final document = LearningDocument(
        id: 'doc-1',
        question: 'question',
        markdown: 'markdown',
        mindmap: 'mindmap',
        keywords: [],
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

      final copied = document.copyWith(markdown: 'updated');

      expect(copied.updatedAt.isAfter(updatedAt), true);
    });
  });
}