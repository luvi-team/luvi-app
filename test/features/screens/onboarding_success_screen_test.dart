import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../support/test_config.dart';

import 'package:luvi_services/user_state_service.dart';

void main() {
  TestConfig.ensureInitialized();
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<Widget> buildApp(
    GoRouter router, {
    Locale locale = const Locale('de'),
    Widget Function(BuildContext, Widget?)? builder,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final service = UserStateService(prefs: prefs);
    return ProviderScope(
      overrides: [
        userStateServiceProvider.overrideWith((ref) async => service),
      ],
      child: MaterialApp.router(
        theme: AppTheme.buildAppTheme(),
        routerConfig: router,
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        builder: builder,
      ),
    );
  }

  group('OnboardingSuccessScreen', () {
    testWidgets(
      'displays trophy, title, and button without back/step counter',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: OnboardingSuccessScreen.routeName,
              builder: (context, state) => const OnboardingSuccessScreen(
                fitnessLevel: FitnessLevel.unknown,
              ),
            ),
          ],
          initialLocation: OnboardingSuccessScreen.routeName,
        );

        await tester.pumpWidget(await buildApp(router));
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsNothing);
        expect(find.byType(LottieBuilder), findsOneWidget);
        final screenContext = tester.element(
          find.byType(OnboardingSuccessScreen),
        );
        final l10n = AppLocalizations.of(screenContext)!;

        expect(find.text(l10n.onboardingSuccessTitle), findsOneWidget);
        expect(find.byKey(const Key('onboarding_success_cta')), findsOneWidget);
        expect(find.text(l10n.commonStartNow), findsOneWidget);
        expect(find.byType(BackButtonCircle), findsNothing);
        expect(find.textContaining('/8'), findsNothing);
      },
    );

    testWidgets('button navigates to dashboard', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
          GoRoute(
            path: HeuteScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard')),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final screenContext = tester.element(
        find.byType(OnboardingSuccessScreen),
      );
      final l10n = AppLocalizations.of(screenContext)!;

      expect(find.text(l10n.onboardingSuccessTitle), findsOneWidget);

      final cta = find.byKey(const Key('onboarding_success_cta'));
      expect(cta, findsOneWidget);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
      final currentUri = router.routeInformationProvider.value.uri.toString();
      expect(currentUri, HeuteScreen.routeName);
    });

    testWidgets('displays correct English strings', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        await buildApp(router, locale: const Locale('en')),
      );
      await tester.pumpAndSettle();

      final screenContext = tester.element(
        find.byType(OnboardingSuccessScreen),
      );
      final l10n = AppLocalizations.of(screenContext)!;

      expect(find.text(l10n.onboardingSuccessTitle), findsOneWidget);
      expect(find.text(l10n.commonStartNow), findsOneWidget);
    });

    testWidgets('celebration animation respects disableAnimations flags', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        await buildApp(
          router,
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(disableAnimations: true),
              child: child!,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(LottieBuilder), findsNothing);
    });

    testWidgets('celebration animation respects accessibleNavigation flag', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        await buildApp(
          router,
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(accessibleNavigation: true),
              child: child!,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Image), findsOneWidget);
      expect(find.byType(LottieBuilder), findsNothing);
    });

    testWidgets('uses correct spacing tokens from Figma audit', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      // Set test size to design viewport (428×926) to avoid scaling
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing = OnboardingSpacing.of(context);

      // From updated spec: trophyToTitle = 28px, titleToButton = design token value
      expect(spacing.trophyToTitle, OnboardingSuccessTokens.gapToTitle);
      expect(spacing.titleToButton, OnboardingSuccessTokens.titleToButton);

      // Reset view size
      addTearDown(tester.view.reset);
    });

    testWidgets('trophy-to-title gap matches responsive spacing', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final trophyFinder = find.byKey(const Key('onboarding_success_trophy'));
      final titleFinder = find.byKey(const Key('onboarding_success_title'));
      expect(trophyFinder, findsOneWidget);
      expect(titleFinder, findsOneWidget);

      final context = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing = OnboardingSpacing.of(context);

      final trophyBottomDy = tester.getBottomLeft(trophyFinder).dy;
      final titleTopDy = tester.getTopLeft(titleFinder).dy;

      expect(titleTopDy - trophyBottomDy, closeTo(spacing.trophyToTitle, 0.01));
    });

    testWidgets('trophy has correct size from Figma audit', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final trophyBoxFinder = find.descendant(
        of: find.byType(ExcludeSemantics),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is SizedBox &&
              widget.width == OnboardingSuccessTokens.trophyWidth &&
              widget.height == OnboardingSuccessTokens.trophyHeight,
        ),
      );
      // From Figma audit: Trophy bounding box 308×300px
      expect(trophyBoxFinder, findsOneWidget);

      final sizedBox = tester.widget<SizedBox>(trophyBoxFinder);
      expect(sizedBox.width, OnboardingSuccessTokens.trophyWidth);
      expect(sizedBox.height, OnboardingSuccessTokens.trophyHeight);
    });

    testWidgets('spacing scales with view height and text scale', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      // Test Scenario 1: Taller view (height > 926)
      tester.view.physicalSize = const Size(428, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final context1 = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing1 = OnboardingSpacing.of(context1);

      // Spacing should be scaled UP (taller view)
      expect(
        spacing1.trophyToTitle,
        greaterThan(OnboardingSuccessTokens.gapToTitle),
      );
      expect(spacing1.titleToButton, greaterThan(66.0));

      tester.view.reset();

      // Test Scenario 2: Increased text scale factor
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        await buildApp(
          router,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.5)),
            child: child!,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context2 = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing2 = OnboardingSpacing.of(context2);

      // Spacing should be scaled UP (text scale > 1.0)
      expect(
        spacing2.trophyToTitle,
        greaterThan(OnboardingSuccessTokens.gapToTitle),
      );
      expect(spacing2.titleToButton, greaterThan(66.0));

      addTearDown(tester.view.reset);
    });

    testWidgets('celebration animation uses expected configuration', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final lottieFinder = find.byType(LottieBuilder);
      expect(lottieFinder, findsOneWidget);

      final lottie = tester.widget<LottieBuilder>(lottieFinder);
      expect(lottie.repeat, isFalse);
      expect(lottie.frameRate, FrameRate.composition);
      expect(lottie.fit, BoxFit.contain);
      expect(lottie.alignment, Alignment.center);
      expect(lottie.filterQuality, FilterQuality.medium);
    });

    testWidgets('celebration animation accounts for safe-area padding', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(428, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(await buildApp(router));
      await tester.pumpAndSettle();

      final transformNoPadding = tester.widget<Transform>(
        find.byKey(const Key('onboarding_success_trophy_transform')),
      );
      final noPaddingOffset = transformNoPadding.transform.storage[13];

      await tester.pumpWidget(
        await buildApp(
          router,
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(
                padding: const EdgeInsets.only(top: 44, bottom: 34),
              ),
              child: child!,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final transformWithPadding = tester.widget<Transform>(
        find.byKey(const Key('onboarding_success_trophy_transform')),
      );
      final paddingOffset = transformWithPadding.transform.storage[13];

      expect(paddingOffset, lessThan(noPaddingOffset));
    });

    testWidgets('a11y fallback shows PNG with correct dimensions', (
      tester,
    ) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(
              fitnessLevel: FitnessLevel.unknown,
            ),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        await buildApp(
          router,
          builder: (context, child) {
            final data = MediaQuery.of(context);
            return MediaQuery(
              data: data.copyWith(disableAnimations: true),
              child: child!,
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final image = tester.widget<Image>(imageFinder);
      expect(image.width, OnboardingSuccessTokens.trophyWidth);
      expect(image.height, OnboardingSuccessTokens.trophyHeight);
      expect(image.fit, BoxFit.contain);

      final assetImage = image.image as AssetImage;
      expect(assetImage.assetName, Assets.images.onboardingSuccessTrophy);
    });
  });
}
