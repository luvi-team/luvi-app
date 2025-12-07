import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/consent/widgets/welcome_video_player.dart';
import '../../../support/test_config.dart';
import '../../../support/test_app.dart';

void main() {
  TestConfig.ensureInitialized();

  group('WelcomeVideoPlayer', () {
    testWidgets('renders with ExcludeSemantics wrapper', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'assets/videos/welcome/welcome_01.mp4',
            ),
          ),
        ),
      );

      // Video is decorative, so it should be excluded from semantics
      // Find ExcludeSemantics that is a descendant of WelcomeVideoPlayer
      final excludeSemanticsInPlayer = find.descendant(
        of: find.byType(WelcomeVideoPlayer),
        matching: find.byType(ExcludeSemantics),
      );
      expect(excludeSemanticsInPlayer, findsOneWidget);
    });

    testWidgets('shows loading state initially (SizedBox.expand)', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'assets/videos/welcome/welcome_01.mp4',
            ),
          ),
        ),
      );

      // Before video initializes, should show SizedBox.expand
      // (video_player requires platform channels that aren't available in tests)
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('handles invalid asset gracefully with error fallback', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'invalid/nonexistent.mp4',
            ),
          ),
        ),
      );

      // Use pumpAndSettle with timeout for robust async error handling
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Widget should still be in the tree (not crash)
      expect(find.byType(WelcomeVideoPlayer), findsOneWidget);
    });

    testWidgets('widget type is correctly identified', (tester) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'assets/videos/welcome/welcome_01.mp4',
            ),
          ),
        ),
      );

      // Should build without errors and be findable by type
      expect(find.byType(WelcomeVideoPlayer), findsOneWidget);
    });

    testWidgets('renders fallback image while loading when fallbackAsset provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'assets/videos/welcome/welcome_01.mp4',
              fallbackAsset: 'assets/images/welcome/welcome_01_fallback.png',
            ),
          ),
        ),
      );

      // Before video initializes, should show fallback Image
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('renders fallback image on error with fallbackAsset', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: const Scaffold(
            body: WelcomeVideoPlayer(
              assetPath: 'invalid/nonexistent.mp4',
              fallbackAsset: 'assets/images/welcome/welcome_01_fallback.png',
            ),
          ),
        ),
      );

      // Use pumpAndSettle with timeout for robust async error handling
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should show fallback Image on error
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('respects reduce-motion accessibility setting', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildLocalizedApp(
          theme: AppTheme.buildAppTheme(),
          home: MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: const Scaffold(
              body: WelcomeVideoPlayer(
                assetPath: 'assets/videos/welcome/welcome_01.mp4',
                fallbackAsset: 'assets/images/welcome/welcome_01_fallback.png',
                honorReduceMotion: true,
              ),
            ),
          ),
        ),
      );

      // With reduce-motion enabled, should immediately show fallback Image
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
