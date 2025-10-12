import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('de_DE', null);
  });
  group('HeuteScreen', () {
    testWidgets('renders key dashboard sections', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Check that section titles are rendered
      final ctx = tester.element(find.byType(HeuteScreen));
      final loc = AppLocalizations.of(ctx)!;
      expect(find.text(loc.dashboardCategoriesTitle), findsOneWidget);
      expect(find.text(loc.dashboardMoreTrainingsTitle), findsOneWidget);
      expect(find.text(loc.dashboardTrainingDataTitle), findsOneWidget);
    });

    testWidgets('renders 4 category labels', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      // Check that all 4 category labels are present
      final ctx = tester.element(find.byType(HeuteScreen));
      final loc = AppLocalizations.of(ctx)!;
      expect(find.text(loc.dashboardCategoryTraining), findsOneWidget);
      expect(find.text(loc.dashboardCategoryNutrition), findsOneWidget);
      expect(find.text(loc.dashboardCategoryRegeneration), findsOneWidget);
      expect(find.text(loc.dashboardCategoryMindfulness), findsOneWidget);
    });

    testWidgets('renders horizontal list with 3 recommendation cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Check that the 3 recommendation titles are present
      expect(find.text('Beine & Po'), findsOneWidget);
      expect(find.text('Rücken & Schulter'), findsOneWidget);
      expect(find.text('Ganzkörper'), findsOneWidget);
    });

    testWidgets('renders training stats scroller with glass cards', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          home: const HeuteScreen(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();
      await tester.drag(find.byType(CustomScrollView), const Offset(0, -900));
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('dashboard_training_stats_scroller')),
        findsOneWidget,
      );
      expect(find.text('Puls'), findsOneWidget);
      expect(find.text('Verbrannte\nEnergie'), findsOneWidget);
      expect(find.text('Schritte'), findsOneWidget);
      expect(find.text('bpm'), findsOneWidget);
      expect(find.text('2.500'), findsOneWidget);
    });
  });
}
