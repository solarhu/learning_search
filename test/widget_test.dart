import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:learning_search/main.dart';

void main() {
  testWidgets('HomePage displays search interface', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('递进式学习搜索'), findsOneWidget);
    expect(find.widgetWithText(TextField, '输入问题进行搜索'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, '搜索'), findsOneWidget);
  });

  testWidgets('Search button is disabled when input is empty', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final searchButton = find.widgetWithText(ElevatedButton, '搜索');
    final textField = find.widgetWithText(TextField, '输入问题进行搜索');

    await tester.enterText(textField, '');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(searchButton).enabled, false);
  });

  testWidgets('Search button is enabled when input has text', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final searchButton = find.widgetWithText(ElevatedButton, '搜索');
    final textField = find.widgetWithText(TextField, '输入问题进行搜索');

    await tester.enterText(textField, '什么是人工智能');
    await tester.pump();

    expect(tester.widget<ElevatedButton>(searchButton).enabled, true);
  });
}