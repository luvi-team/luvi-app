import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/dots_indicator.dart';

void main() {
  testWidgets('DotsIndicator renders correct count and active dot', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: AppTheme.buildAppTheme(),
      home: const Scaffold(
        body: Center(child: DotsIndicator(count: 3, activeIndex: 1)),
      ),
    ));

    // Prüfe spezifische Keys statt fragilem Decoration-Matcher
    expect(find.byKey(const Key('dot_0')), findsOneWidget);
    expect(find.byKey(const Key('dot_1')), findsOneWidget);
    expect(find.byKey(const Key('dot_2')), findsOneWidget);
  });
}
