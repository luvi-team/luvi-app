import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/welcome/screens/welcome_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'support/test_config.dart';
import 'support/video_player_mock.dart';

void main() {
  TestConfig.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    // WelcomeScreen uses WelcomeVideoPlayer which needs the video platform mock
    VideoPlayerMock.registerWith();
  });

  testWidgets('Welcome screen title renders for de locale', (tester) async {
    // Use realistic phone screen size (iPhone 14 Pro dimensions)
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          locale: const Locale('de'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(WelcomeScreen)),
    )!;

    // First page title should be visible
    expect(find.text(l10n.welcomeNewTitle1), findsOneWidget);
  });

  testWidgets('Welcome screen title renders for en locale', (tester) async {
    // Use realistic phone screen size (iPhone 14 Pro dimensions)
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          theme: AppTheme.buildAppTheme(),
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const WelcomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = AppLocalizations.of(
      tester.element(find.byType(WelcomeScreen)),
    )!;

    // First page title should be visible
    expect(find.text(l10n.welcomeNewTitle1), findsOneWidget);
  });
}
