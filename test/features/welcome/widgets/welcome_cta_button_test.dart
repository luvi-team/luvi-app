import 'dart:ui' show Tristate;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/welcome/widgets/welcome_cta_button.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  late List<MethodCall> hapticCalls;

  setUp(() {
    hapticCalls = [];
    // Mock HapticFeedback.lightImpact() to avoid MissingPluginException
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      SystemChannels.platform,
      (MethodCall call) async {
        if (call.method == 'HapticFeedback.vibrate') {
          hapticCalls.add(call);
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  group('WelcomeCtaButton', () {
    testWidgets('renders label text when isLoading=false', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Test Label',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Test Label'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows CircularProgressIndicator when isLoading=true',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Loading Test',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label Text widget is not rendered during loading (swapped for CircularProgressIndicator)
      expect(find.text('Loading Test'), findsNothing);
    });

    testWidgets('triggers onPressed callback and haptic feedback on tap',
        (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Tap Me',
                onPressed: () => wasPressed = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(wasPressed, isTrue);
      expect(hapticCalls, isNotEmpty);
    });

    testWidgets('button is disabled when isLoading=true', (tester) async {
      var wasPressed = false;

      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Disabled Loading',
                onPressed: () => wasPressed = true,
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      // Find ElevatedButton and verify onPressed is null
      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);

      // Attempt tap should not trigger callback
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      expect(wasPressed, isFalse);
    });

    testWidgets('button is disabled when onPressed is null', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Disabled Null',
                onPressed: null,
              ),
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('has correct Semantics with label and enabled state',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Semantic Button',
                onPressed: () {},
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(WelcomeCtaButton));
      expect(semantics.label, equals('Semantic Button'));
      expect(semantics.flagsCollection.isButton, isTrue);
      // Flutter 3.38+: isEnabled returns Tristate, not bool
      expect(semantics.flagsCollection.isEnabled, Tristate.isTrue);
    });

    testWidgets('Semantics shows enabled=false when isLoading=true',
        (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: Scaffold(
            body: Center(
              child: WelcomeCtaButton(
                label: 'Loading Semantics',
                onPressed: () {},
                isLoading: true,
              ),
            ),
          ),
        ),
      );

      final semantics = tester.getSemantics(find.byType(WelcomeCtaButton));
      expect(semantics.label, equals('Loading Semantics'));
      // Flutter 3.38+: isEnabled returns Tristate, not bool
      expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
    });
  });
}
