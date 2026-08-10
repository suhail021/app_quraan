import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:Quran/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuranApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
