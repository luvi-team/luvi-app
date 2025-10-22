import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/onboarding_spacing.dart';
import 'package:luvi_app/core/design_tokens/onboarding_success_tokens.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/screens/heute_screen.dart';
import 'package:luvi_app/features/screens/onboarding_success_screen.dart';
import 'package:luvi_app/features/widgets/back_button.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('OnboardingSuccessScreen', () {
    testWidgets(
      'displays trophy, title, and button without back/step counter',
      (tester) async {
        final router = GoRouter(
          routes: [
            GoRoute(
              path: OnboardingSuccessScreen.routeName,
              builder: (context, state) => const OnboardingSuccessScreen(),
            ),
          ],
          initialLocation: OnboardingSuccessScreen.routeName,
        );

        await tester.pumpWidget(
          MaterialApp.router(
            theme: AppTheme.buildAppTheme(),
            routerConfig: router,
            locale: const Locale('de'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(Image), findsOneWidget);
        expect(find.byType(LottieBuilder), findsOneWidget);
        expect(find.text('Du bist startklar!'), findsOneWidget);
        expect(find.byKey(const Key('onboarding_success_cta')), findsOneWidget);
        expect(find.text("Los geht's!"), findsOneWidget);
        expect(find.byType(BackButtonCircle), findsNothing);
        expect(find.textContaining('/8'), findsNothing);
      },
    );

    testWidgets('button navigates to dashboard', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
          GoRoute(
            path: HeuteScreen.routeName,
            builder: (context, state) =>
                const Scaffold(body: Text('Dashboard')),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Du bist startklar!'), findsOneWidget);

      final cta = find.byKey(const Key('onboarding_success_cta'));
      expect(cta, findsOneWidget);
      await tester.tap(cta);
      await tester.pumpAndSettle();

      expect(find.text('Dashboard'), findsOneWidget);
    });

    testWidgets('displays correct English strings', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text("You're ready to go!"), findsOneWidget);
      expect(find.text("Let's go!"), findsOneWidget);
    });

    testWidgets('confetti animation respects disableAnimations flags',
        (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
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

      expect(find.byType(LottieBuilder), findsNothing);
    });

    testWidgets('uses correct spacing tokens from Figma audit', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      // Set test size to design viewport (428×926) to avoid scaling
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing = OnboardingSpacing.of(context);

      // From Figma audit ONB_SUCCESS_measures.json:
      // trophyToTitle = 28px, titleToButton = 66px
      expect(spacing.trophyToTitle, 28.0);
      expect(spacing.titleToButton, 66.0);

      // Reset view size
      addTearDown(tester.view.reset);
    });

    testWidgets('trophy has correct size from Figma audit', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final trophyFinder = find.byType(Image);
      expect(trophyFinder, findsOneWidget);

      final trophy = tester.widget<Image>(trophyFinder);
      // From Figma audit: Trophy bounding box 308×300px
      expect(trophy.width, OnboardingSuccessTokens.trophyWidth);
      expect(trophy.height, OnboardingSuccessTokens.trophyHeight);
    });

    testWidgets('spacing scales with view height and text scale', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      // Test Scenario 1: Taller view (height > 926)
      tester.view.physicalSize = const Size(428, 1200);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final context1 = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing1 = OnboardingSpacing.of(context1);

      // Spacing should be scaled UP (taller view)
      expect(spacing1.trophyToTitle, greaterThan(28.0));
      expect(spacing1.titleToButton, greaterThan(66.0));

      tester.view.reset();

      // Test Scenario 2: Increased text scale factor
      tester.view.physicalSize = const Size(428, 926);
      tester.view.devicePixelRatio = 1.0;

      await tester.pumpWidget(
        Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: const TextScaler.linear(1.5),
            ),
            child: MaterialApp.router(
              theme: AppTheme.buildAppTheme(),
              routerConfig: router,
              locale: const Locale('de'),
              supportedLocales: AppLocalizations.supportedLocales,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final context2 = tester.element(find.byType(OnboardingSuccessScreen));
      final spacing2 = OnboardingSpacing.of(context2);

      // Spacing should be scaled UP (text scale > 1.0)
      expect(spacing2.trophyToTitle, greaterThan(28.0));
      expect(spacing2.titleToButton, greaterThan(66.0));

      addTearDown(tester.view.reset);
    });

    testWidgets('confetti animation uses expected configuration', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: OnboardingSuccessScreen.routeName,
            builder: (context, state) => const OnboardingSuccessScreen(),
          ),
        ],
        initialLocation: OnboardingSuccessScreen.routeName,
      );

      await tester.pumpWidget(
        MaterialApp.router(
          theme: AppTheme.buildAppTheme(),
          routerConfig: router,
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      );
      await tester.pumpAndSettle();

      final lottieFinder = find.byType(LottieBuilder);
      expect(lottieFinder, findsOneWidget);

      final lottie = tester.widget<LottieBuilder>(lottieFinder);
      expect(lottie.repeat, isFalse);
      expect(lottie.frameRate, FrameRate.composition);
      expect(lottie.fit, BoxFit.contain);
      expect(lottie.alignment, Alignment.topCenter);
      expect(lottie.filterQuality, FilterQuality.medium);

      final positionedFinder = find.byType(Positioned);
      expect(positionedFinder, findsOneWidget);

      final positioned = tester.widget<Positioned>(positionedFinder);
      expect(positioned.top, OnboardingSuccessTokens.confettiVerticalOffset);
    });
  });
}
