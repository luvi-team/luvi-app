// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luvi_app/main_prod.dart';

void main() {
  testWidgets('ConsentProdApp loads and routes to welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: ConsentProdApp()));
    
    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that the welcome screen loads by checking for the CTA button
    expect(find.byKey(const Key('welcome1_cta')), findsOneWidget);
    expect(find.text('Weiter'), findsOneWidget);
  });
}
