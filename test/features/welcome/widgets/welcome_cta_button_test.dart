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
      // Label text should be hidden during loading (ExcludeSemantics wraps it)
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

      // Find Semantics widgets and filter for the one with our label
      final allSemantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(WelcomeCtaButton),
          matching: find.byType(Semantics),
        ),
      );

      final labeledSemantics = allSemantics
          .where((s) => s.properties.label == 'Semantic Button')
          .toList();
      expect(labeledSemantics, hasLength(1));

      final semantics = labeledSemantics.first;
      expect(semantics.properties.button, isTrue);
      expect(semantics.properties.enabled, isTrue);
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

      // Find Semantics widgets and filter for the one with our label
      final allSemantics = tester.widgetList<Semantics>(
        find.descendant(
          of: find.byType(WelcomeCtaButton),
          matching: find.byType(Semantics),
        ),
      );

      final labeledSemantics = allSemantics
          .where((s) => s.properties.label == 'Loading Semantics')
          .toList();
      expect(labeledSemantics, hasLength(1));

      final semantics = labeledSemantics.first;
      expect(semantics.properties.enabled, isFalse);
    });
  });
}
