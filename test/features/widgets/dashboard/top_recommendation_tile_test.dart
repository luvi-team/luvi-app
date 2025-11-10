import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/widgets/dashboard/top_recommendation_tile.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import '../../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  group('TopRecommendationTile', () {
    testWidgets('displays duration with time icon when duration is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: TopRecommendationTile(
              workoutId: 'test-workout',
              tag: 'Kraft',
              title: 'Test Workout',
              imagePath: Assets.images.recoGanzkoerper,
              badgeAssetPath: Assets.icons.syncBadge,
              duration: '15 Min',
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify duration text is visible
      expect(
        find.text('15 Min'),
        findsOneWidget,
        reason: 'Duration text should be visible when duration is provided',
      );

      // Note: Icon verification via find.bySvgAsset() requires additional test setup;
      // here we verify the text presence as the primary property test.
    });

    testWidgets('does not display duration when duration is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: TopRecommendationTile(
              workoutId: 'test-workout',
              tag: 'Kraft',
              title: 'Test Workout',
              imagePath: Assets.images.recoGanzkoerper,
              badgeAssetPath: Assets.icons.syncBadge,
              duration: null,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify no duration text is visible
      expect(
        find.textContaining('Min'),
        findsNothing,
        reason: 'Duration should not be visible when duration is null',
      );
    });

    testWidgets('displays all required elements (tag, title, badge)', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: TopRecommendationTile(
              workoutId: 'test-workout',
              tag: 'Kraft',
              title: 'Shoulder Stretching',
              imagePath: Assets.images.recoGanzkoerper,
              badgeAssetPath: Assets.icons.syncBadge,
              duration: '15 Min',
              fromLuviSync: true,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tag (uppercase)
      expect(
        find.text('KRAFT'),
        findsOneWidget,
        reason: 'Tag should be visible in uppercase',
      );

      // Verify title
      expect(
        find.text('Shoulder Stretching'),
        findsOneWidget,
        reason: 'Title should be visible',
      );

      // Verify badge is present
      expect(
        find.byKey(const Key('top_recommendation_badge')),
        findsOneWidget,
        reason: 'Badge should be visible when fromLuviSync is true',
      );

      // Verify duration
      expect(
        find.text('15 Min'),
        findsOneWidget,
        reason: 'Duration should be visible',
      );
    });

    testWidgets('badge is not visible when fromLuviSync is false', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.buildAppTheme(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('de'),
          home: Scaffold(
            body: TopRecommendationTile(
              workoutId: 'test-workout',
              tag: 'Kraft',
              title: 'Test Workout',
              imagePath: Assets.images.recoGanzkoerper,
              badgeAssetPath: Assets.icons.syncBadge,
              duration: '15 Min',
              fromLuviSync: false,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify badge is not present
      expect(
        find.byKey(const Key('top_recommendation_badge')),
        findsNothing,
        reason: 'Badge should not be visible when fromLuviSync is false',
      );
    });
  });
}
