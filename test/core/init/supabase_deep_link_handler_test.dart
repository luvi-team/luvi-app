import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/supabase_deep_link_handler.dart';
import 'package:mocktail/mocktail.dart';

class MockAppLinks extends Mock implements AppLinks {}

void main() {
  group('SupabaseDeepLinkHandler', () {
    late MockAppLinks mockAppLinks;
    late StreamController<Uri> uriStreamController;

    setUp(() {
      mockAppLinks = MockAppLinks();
      uriStreamController = StreamController<Uri>.broadcast();

      // Default stubs
      when(() => mockAppLinks.getInitialLink()).thenAnswer((_) async => null);
      when(() => mockAppLinks.uriLinkStream)
          .thenAnswer((_) => uriStreamController.stream);
    });

    tearDown(() async {
      await uriStreamController.close();
    });

    group('Lifecycle', () {
      test('throws StateError when start() called after dispose()', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.dispose();

        expect(
          () => handler.start(),
          throwsA(isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('disposed'),
          )),
        );
      });

      test('start() can only be called once (idempotent)', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();
        await handler.start(); // Should not throw, just return early

        // Verify getInitialLink was only called once
        verify(() => mockAppLinks.getInitialLink()).called(1);

        await handler.dispose();
      });

      test('dispose cancels subscription and marks as disposed', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();
        await handler.dispose();

        // After dispose, start should throw
        expect(() => handler.start(), throwsStateError);
      });
    });

    group('hasPendingUri', () {
      test('initially returns false', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        expect(handler.hasPendingUri, isFalse);

        await handler.dispose();
      });

      test('returns true after matching URI received (Supabase not initialized)',
          () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        // Simulate incoming deep link matching the allowed URI
        // Note: Since SupabaseService.isInitialized is false in tests,
        // the URI should be queued as pending
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=test'));

        // Allow stream to process
        await Future<void>.delayed(Duration.zero);

        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('returns false after non-matching scheme URI received', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        // Send URI with wrong scheme
        uriStreamController.add(Uri.parse('https://auth-callback?code=test'));

        await Future<void>.delayed(Duration.zero);

        expect(handler.hasPendingUri, isFalse);

        await handler.dispose();
      });

      test('returns false after non-matching host URI received', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        // Send URI with wrong host
        uriStreamController.add(Uri.parse('luvi://other-host?code=test'));

        await Future<void>.delayed(Duration.zero);

        expect(handler.hasPendingUri, isFalse);

        await handler.dispose();
      });
    });

    group('Initial URI handling', () {
      test('processes initial URI on start if it matches', () async {
        final initialUri = Uri.parse('luvi://auth-callback?code=initial');

        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => initialUri);

        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        // Since Supabase is not initialized in tests, URI should be pending
        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('ignores initial URI if it does not match', () async {
        final initialUri = Uri.parse('https://other-domain.com/callback');

        when(() => mockAppLinks.getInitialLink())
            .thenAnswer((_) async => initialUri);

        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        expect(handler.hasPendingUri, isFalse);

        await handler.dispose();
      });
    });

    group('Allowlist matching', () {
      test('case-insensitive scheme matching', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('LUVI://auth-callback'),
        );

        await handler.start();

        // Send URI with lowercase scheme
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=test'));

        await Future<void>.delayed(Duration.zero);

        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('case-insensitive host matching', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://AUTH-CALLBACK'),
        );

        await handler.start();

        // Send URI with lowercase host
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=test'));

        await Future<void>.delayed(Duration.zero);

        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });
    });

    group('Path normalization', () {
      test('matches paths with and without trailing slash', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback/path'),
        );

        await handler.start();

        // Path without trailing slash
        uriStreamController.add(Uri.parse('luvi://auth-callback/path?code=test'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('matches paths with trailing slash against allowed without', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback/path'),
        );

        await handler.start();

        // Path WITH trailing slash should match allowed WITHOUT
        uriStreamController.add(Uri.parse('luvi://auth-callback/path/?code=test'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('matches paths without trailing slash against allowed with', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback/path/'),
        );

        await handler.start();

        // Path WITHOUT trailing slash should match allowed WITH
        uriStreamController.add(Uri.parse('luvi://auth-callback/path?code=test'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });

      test('case-insensitive path matching', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback/PATH'),
        );

        await handler.start();

        uriStreamController.add(Uri.parse('luvi://auth-callback/path?code=test'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.hasPendingUri, isTrue);

        await handler.dispose();
      });
    });

    group('overwrittenUriCount', () {
      test('initially returns zero', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        expect(handler.overwrittenUriCount, equals(0));

        await handler.dispose();
      });

      test('increments when pending URI is replaced', () async {
        final handler = SupabaseDeepLinkHandler(
          appLinks: mockAppLinks,
          allowedUri: Uri.parse('luvi://auth-callback'),
        );

        await handler.start();

        // First URI queued
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=first'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.overwrittenUriCount, equals(0));

        // Second URI overwrites first
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=second'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.overwrittenUriCount, equals(1));

        // Third URI overwrites second
        uriStreamController.add(Uri.parse('luvi://auth-callback?code=third'));
        await Future<void>.delayed(Duration.zero);
        expect(handler.overwrittenUriCount, equals(2));

        await handler.dispose();
      });
    });
  });
}
