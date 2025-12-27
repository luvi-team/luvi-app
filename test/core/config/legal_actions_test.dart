import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/config/legal_actions.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';

import '../../support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();

  group('legal_actions', () {
    group('openPrivacy', () {
      testWidgets('uses appLinksProvider to get privacy URL', (tester) async {
        // Arrange: Build a minimal app with ProviderScope
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const MaterialApp(home: Scaffold());
              },
            ),
          ),
        );

        // Act: Read appLinks via the captured ref
        final appLinks = capturedRef.read(appLinksProvider);

        // Assert: Provider returns valid AppLinks
        expect(appLinks, isA<AppLinksApi>());
        expect(appLinks.privacyPolicy, isA<Uri>());
      });
    });

    group('openTerms', () {
      testWidgets('uses appLinksProvider to get terms URL', (tester) async {
        // Arrange: Build a minimal app with ProviderScope
        late WidgetRef capturedRef;
        await tester.pumpWidget(
          ProviderScope(
            child: Consumer(
              builder: (context, ref, _) {
                capturedRef = ref;
                return const MaterialApp(home: Scaffold());
              },
            ),
          ),
        );

        // Act: Read appLinks via the captured ref
        final appLinks = capturedRef.read(appLinksProvider);

        // Assert: Provider returns valid AppLinks
        expect(appLinks, isA<AppLinksApi>());
        expect(appLinks.termsOfService, isA<Uri>());
      });
    });

    group('fallback routes', () {
      test('RoutePaths.legalPrivacy is the privacy fallback', () {
        expect(RoutePaths.legalPrivacy, equals('/legal/privacy'));
      });

      test('RoutePaths.legalTerms is the terms fallback', () {
        expect(RoutePaths.legalTerms, equals('/legal/terms'));
      });
    });

    group('function signatures', () {
      test('openPrivacy requires BuildContext and WidgetRef', () {
        // This test verifies the function signature at compile time
        // If the signature changes, this test will fail to compile
        expect(openPrivacy, isA<Future<void> Function(BuildContext, WidgetRef)>());
      });

      test('openTerms requires BuildContext and WidgetRef', () {
        // This test verifies the function signature at compile time
        // If the signature changes, this test will fail to compile
        expect(openTerms, isA<Future<void> Function(BuildContext, WidgetRef)>());
      });
    });
  });
}
