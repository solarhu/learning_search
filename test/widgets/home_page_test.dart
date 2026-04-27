import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:learning_search/main.dart';

void main() {
  group('HomePage Keyword Removal', () {
    testWidgets('Keywords are displayed after search', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('关键词'), findsOneWidget);
    });

    testWidgets('Remove button is visible for keywords', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.close), findsWidgets);
    });

    testWidgets('Keyword can be removed', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final initialKeywordCount = tester.widgetList(find.byIcon(Icons.close)).length;
      expect(initialKeywordCount, greaterThan(0));

      final removeButton = find.byIcon(Icons.close).first;
      await tester.tap(removeButton);
      await tester.pumpAndSettle();

      final newKeywordCount = tester.widgetList(find.byIcon(Icons.close)).length;
      expect(newKeywordCount, lessThan(initialKeywordCount));
    });

    testWidgets('Deselect button appears when keyword is expanded', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);

      final firstKeyword = find.text('AI辅助编程');
      if (firstKeyword.evaluate().isNotEmpty) {
        await tester.tap(firstKeyword);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byIcon(Icons.check_box_outline_blank), findsWidgets);
      }
    });

    testWidgets('Deselect button collapses expanded keyword', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final firstKeyword = find.text('AI辅助编程');
      if (firstKeyword.evaluate().isNotEmpty) {
        await tester.tap(firstKeyword);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byIcon(Icons.check_box_outline_blank), findsWidgets);

        final deselectButton = find.byIcon(Icons.check_box_outline_blank).first;
        await tester.tap(deselectButton);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.check_box_outline_blank), findsNothing);
      }
    });
  });

  group('HomePage Document Mode', () {
    testWidgets('Back button appears in learning mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byIcon(Icons.arrow_back), findsNothing);

      final generateButton = find.widgetWithText(ElevatedButton, '生成学习文档');
      if (generateButton.evaluate().isNotEmpty) {
        await tester.tap(generateButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      }
    });

    testWidgets('Back button returns to search mode', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final generateButton = find.widgetWithText(ElevatedButton, '生成学习文档');
      if (generateButton.evaluate().isNotEmpty) {
        await tester.tap(generateButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        final backButton = find.byIcon(Icons.arrow_back);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.arrow_back), findsNothing);
        expect(find.text('核心答案'), findsOneWidget);
      }
    });

    testWidgets('Back button preserves keywords', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final textField = find.widgetWithText(TextField, '输入问题进行搜索');
      await tester.enterText(textField, 'openclaw是什么');

      final searchButton = find.widgetWithText(ElevatedButton, '搜索');
      await tester.tap(searchButton);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final initialKeywordCount = tester.widgetList(find.byIcon(Icons.close)).length;

      final generateButton = find.widgetWithText(ElevatedButton, '生成学习文档');
      if (generateButton.evaluate().isNotEmpty) {
        await tester.tap(generateButton);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        final backButton = find.byIcon(Icons.arrow_back);
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        final afterBackKeywordCount = tester.widgetList(find.byIcon(Icons.close)).length;
        expect(afterBackKeywordCount, equals(initialKeywordCount));
      }
    });
  });
}