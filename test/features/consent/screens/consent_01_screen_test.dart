import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/screens/consent_01_screen.dart';

void main() {
  group('Consent01Screen', () {
    late GoRouter router;

    setUp(() {
      router = GoRouter(
        initialLocation: Consent01Screen.routeName,
        routes: [
          GoRoute(
            path: Consent01Screen.routeName,
            builder: (context, state) => const Consent01Screen(),
          ),
          GoRoute(
            path: '/consent/02',
            builder: (context, state) => const Scaffold(body: Text('Consent 02')),
          ),
          GoRoute(
            path: '/onboarding/w3',
            builder: (context, state) => const Scaffold(body: Text('Onboarding W3')),
          ),
        ],
      );
    });

    Widget createTestApp() {
      return MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
      );
    }

    testWidgets('displays all UI elements correctly', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Check hero grid is present (4 images)
      expect(find.byType(Image), findsNWidgets(4));

      expect(find.textContaining('Lass uns LUVI'), findsOneWidget);

      // Check subtitle
      expect(find.textContaining('Du entscheidest, was du teilen möchtest.'), findsOneWidget);

      // Check navigation buttons
      expect(find.text('Weiter'), findsOneWidget);
      expect(find.text('Überspringen'), findsOneWidget);

      // Check back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });

    testWidgets('hero grid has correct layout', (tester) async {
      await tester.pumpWidget(createTestApp());

      final gridView = find.byType(GridView);
      expect(gridView, findsOneWidget);

      // Verify 2x2 grid structure
      final GridView grid = tester.widget(gridView);
      expect((grid.childrenDelegate as SliverChildListDelegate).children.length, 4);
    });

    testWidgets('back button has correct styling', (tester) async {
      await tester.pumpWidget(createTestApp());

      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);

      // Check parent container size
      final sizedBox = find.ancestor(
        of: backButton,
        matching: find.byType(SizedBox),
      ).first;
      
      final SizedBox box = tester.widget(sizedBox);
      expect(box.width, 40);
      expect(box.height, 40);
    });

    testWidgets('back button navigates to onboarding w3', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Onboarding W3'), findsOneWidget);
    });

    testWidgets('weiter button navigates to consent/02', (tester) async {
      await tester.pumpWidget(createTestApp());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Weiter'));
      await tester.pumpAndSettle();

      expect(find.text('Consent 02'), findsOneWidget);
    });

    testWidgets('has correct accessibility semantics', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Check header semantic - RichText doesn't merge semantics automatically
      // so we check for the Semantics wrapper with header:true
      final semanticsWithHeader = find.byWidgetPredicate(
        (widget) => widget is Semantics && widget.properties.header == true,
      );
      expect(semanticsWithHeader, findsOneWidget);

      // Check back button semantic
      final backButtonSemantics = find.bySemanticsLabel('Zurück');
      expect(backButtonSemantics, findsOneWidget);
    });

    testWidgets('touch targets meet minimum size requirements', (tester) async {
      await tester.pumpWidget(createTestApp());

      // Check Weiter button meets 44x44 minimum
      final weiterButton = find.widgetWithText(ElevatedButton, 'Weiter');
      final weiterButtonSize = tester.getSize(weiterButton);
      expect(weiterButtonSize.height, greaterThanOrEqualTo(44));

      // Check back button is 40x40 (as specified)
      final backButtonContainer = find.ancestor(
        of: find.byIcon(Icons.arrow_back),
        matching: find.byType(SizedBox),
      ).first;
      final backButtonSize = tester.getSize(backButtonContainer);
      expect(backButtonSize.width, 40);
      expect(backButtonSize.height, 40);
    });
  });
}