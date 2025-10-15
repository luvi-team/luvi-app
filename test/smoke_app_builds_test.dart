import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/main.dart';

void main() {
  testWidgets('smoke test: LUVI app builds without crashing', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MyApp()));
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

// trigger CR Sun Sep 28 14:18:19 CEST 2025
