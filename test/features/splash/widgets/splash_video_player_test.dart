import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/features/splash/widgets/splash_video_player.dart';
import '../../../support/video_player_mock.dart';

void main() {
  group('SplashVideoPlayer', () {
    setUp(() {
      // Register fresh mock for each test
      VideoPlayerMock.registerWith();
    });

    group('initialization timeout', () {
      testWidgets('fires onComplete when initialization times out', (
        tester,
      ) async {
        // Mock that never emits initialization event (stream stays open forever)
        VideoPlayerMock.registerWith(neverEmits: true);

        bool completeCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              onComplete: () => completeCalled = true,
              // Short timeout for test (100ms instead of 3s)
              initializationTimeout: const Duration(milliseconds: 100),
            ),
          ),
        );

        // Not called yet
        expect(completeCalled, isFalse);

        // Advance time past timeout
        await tester.pump(const Duration(milliseconds: 100));

        // Now onComplete should have fired
        expect(completeCalled, isTrue);
      });

      testWidgets('fires onComplete exactly once on timeout', (tester) async {
        // Mock that never emits initialization event (stream stays open forever)
        VideoPlayerMock.registerWith(neverEmits: true);

        int callCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              onComplete: () => callCount++,
              initializationTimeout: const Duration(milliseconds: 50),
            ),
          ),
        );

        // Advance past timeout
        await tester.pump(const Duration(milliseconds: 50));
        expect(callCount, equals(1));

        // Pump more time - should not fire again
        await tester.pump(const Duration(milliseconds: 100));
        expect(callCount, equals(1));
      });
    });

    group('reduce motion', () {
      testWidgets('shows fallback and fires onComplete when reduce motion enabled', (
        tester,
      ) async {
        bool completeCalled = false;

        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: true),
            child: MaterialApp(
              home: SplashVideoPlayer(
                assetPath: Assets.videos.splashScreen,
                fallbackAsset: Assets.images.splashFallback,
                onComplete: () => completeCalled = true,
                honorReduceMotion: true,
              ),
            ),
          ),
        );

        // Allow post-frame callback to fire
        await tester.pump();

        // Should show fallback image (Image.asset finder)
        expect(find.byType(Image), findsOneWidget);

        // onComplete should have fired
        expect(completeCalled, isTrue);
      });

      testWidgets('initializes video when reduce motion is disabled', (
        tester,
      ) async {
        await tester.pumpWidget(
          MediaQuery(
            data: const MediaQueryData(disableAnimations: false),
            child: MaterialApp(
              home: SplashVideoPlayer(
                assetPath: Assets.videos.splashScreen,
                fallbackAsset: Assets.images.splashFallback,
                onComplete: () {},
                honorReduceMotion: true,
                // Long timeout so we can verify video initializes
                initializationTimeout: const Duration(seconds: 10),
                maxPlaybackDuration: const Duration(seconds: 10),
              ),
            ),
          ),
        );

        // Allow initialization
        await tester.pumpAndSettle();

        // Video should be initialized (mock emits initialized event)
        // We can verify by checking that fallback is NOT shown after init
        // Note: Mock's buildView returns SizedBox.shrink with key 'mock_video_player'
        expect(find.byKey(const Key('mock_video_player')), findsOneWidget);
      });
    });

    group('error handling', () {
      testWidgets('fires onComplete on invalid asset error', (tester) async {
        bool completeCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              // Intentionally invalid path to trigger error handling
              assetPath: 'assets/videos/invalid_video.mp4',
              fallbackAsset: Assets.images.splashFallback,
              onComplete: () => completeCalled = true,
            ),
          ),
        );

        // Allow error handling to complete
        await tester.pumpAndSettle();

        // onComplete should have fired due to error
        expect(completeCalled, isTrue);

        // Should show fallback image
        expect(find.byType(Image), findsOneWidget);
      });
    });

    group('max playback duration', () {
      testWidgets('fires onComplete after max playback duration', (
        tester,
      ) async {
        bool completeCalled = false;

        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              onComplete: () => completeCalled = true,
              initializationTimeout: const Duration(seconds: 10),
              // Short max duration for test
              maxPlaybackDuration: const Duration(milliseconds: 100),
            ),
          ),
        );

        // Not called yet (initialization happens)
        await tester.pump();
        expect(completeCalled, isFalse);

        // Advance past max playback duration
        await tester.pump(const Duration(milliseconds: 100));

        // Should have fired
        expect(completeCalled, isTrue);
      });
    });

    group('semantics', () {
      testWidgets('excludes video from semantics tree', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              onComplete: () {},
            ),
          ),
        );

        await tester.pump();

        // Should find ExcludeSemantics widget as direct child of SplashVideoPlayer
        // Note: MaterialApp may also have ExcludeSemantics, so we check at least one exists
        expect(find.byType(ExcludeSemantics), findsWidgets);

        // Verify our SplashVideoPlayer wraps content in ExcludeSemantics
        // by checking the widget tree structure
        final splashVideoFinder = find.byType(SplashVideoPlayer);
        expect(splashVideoFinder, findsOneWidget);

        // The first child of SplashVideoPlayer should be ExcludeSemantics
        final excludeSemanticsFinder = find.descendant(
          of: splashVideoFinder,
          matching: find.byType(ExcludeSemantics),
        );
        expect(excludeSemanticsFinder, findsOneWidget);
      });
    });

    group('fallback rendering', () {
      testWidgets('shows fallback during loading', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              fallbackAsset: Assets.images.splashFallback,
              onComplete: () {},
            ),
          ),
        );

        // During first pump, video is still initializing
        // Fallback should be shown
        expect(find.byType(Image), findsOneWidget);
      });

      testWidgets('shows neutral colored box when no fallback provided', (
        tester,
      ) async {
        // Mock that never initializes (stream stays open forever)
        VideoPlayerMock.registerWith(neverEmits: true);

        await tester.pumpWidget(
          MaterialApp(
            home: SplashVideoPlayer(
              assetPath: Assets.videos.splashScreen,
              fallbackAsset: null,
              onComplete: () {},
              initializationTimeout: const Duration(seconds: 10),
            ),
          ),
        );

        await tester.pump();

        // Should show SizedBox.expand with loading key (no fallback image)
        expect(find.byKey(const Key('splash_video_loading')), findsOneWidget);
      });
    });
  });
}
