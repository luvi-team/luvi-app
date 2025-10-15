import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/widgets/verification_code_input.dart';

void main() {
  ThemeData buildTheme() => AppTheme.buildAppTheme();

  Widget wrapWithScaffold(Widget child) {
    return MaterialApp(
      theme: buildTheme(),
      home: Scaffold(body: Center(child: child)),
    );
  }

  testWidgets('paste_fills_all_cells_and_enables_cta', (tester) async {
    String lastCode = '';
    String? completedCode;

    await tester.pumpWidget(
      wrapWithScaffold(
        VerificationCodeInput(
          length: 6,
          autofocus: true,
          onChanged: (value) => lastCode = value,
          onCompleted: (value) => completedCode = value,
        ),
      ),
    );

    await tester.pump();

    final firstField = find.byType(TextField).first;
    await tester.tap(firstField);
    await tester.pump();

    await tester.enterText(firstField, '123456');
    await tester.pump();

    expect(lastCode, '123456');
    expect(completedCode, '123456');

    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(6));

    for (var i = 0; i < 6; i++) {
      final textField = tester.widget<TextField>(textFields.at(i));
      expect(textField.controller?.text, '${i + 1}');
    }
  });

  testWidgets('guard_resets_after_paste_then_typing', (tester) async {
    final codes = <String>[];

    await tester.pumpWidget(
      wrapWithScaffold(
        VerificationCodeInput(length: 6, autofocus: true, onChanged: codes.add),
      ),
    );

    await tester.pump();

    final textFields = find.byType(TextField);
    final firstField = textFields.first;

    await tester.tap(firstField);
    await tester.pump();

    await tester.enterText(firstField, '123456');
    await tester.pump();
    await tester.pump();

    final changesAfterPaste = codes.length;

    final lastField = textFields.at(5);
    await tester.tap(lastField);
    await tester.pump();

    await tester.enterText(lastField, '7');
    await tester.pump();

    expect(codes.length, greaterThan(changesAfterPaste));
    expect(codes.last, '123457');
  });
}
