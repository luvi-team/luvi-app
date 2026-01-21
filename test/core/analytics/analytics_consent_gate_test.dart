import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/analytics/analytics_recorder.dart';
import 'package:luvi_app/core/privacy/consent_types.dart';
import 'package:luvi_services/user_state_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../support/test_config.dart';

class _MockUserStateService extends Mock implements UserStateService {}

void main() {
  TestConfig.ensureInitialized();

  group('Analytics Consent Gating', () {
    group('analyticsConsentGateProvider', () {
      test('returns false when UserStateService is loading', () {
        final container = ProviderContainer(
          overrides: [
            // Simulate loading state by not providing a value
            userStateServiceProvider.overrideWith(
              (ref) => Future.delayed(
                const Duration(days: 1),
                () => _MockUserStateService(),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = container.read(analyticsConsentGateProvider);
        expect(
          result,
          isFalse,
          reason: 'Loading state should fail-safe to no analytics',
        );
      });

      test('returns false when UserStateService throws error', () {
        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider.overrideWith(
              (ref) => Future<UserStateService>.error(
                StateError('Test error'),
              ),
            ),
          ],
        );
        addTearDown(container.dispose);

        final result = container.read(analyticsConsentGateProvider);
        expect(
          result,
          isFalse,
          reason: 'Error state should fail-safe to no analytics',
        );
      });

      test('returns false when consent scopes are null', () async {
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull).thenReturn(null);

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
          ],
        );
        addTearDown(container.dispose);

        // Wait for the async provider to resolve
        await container.read(userStateServiceProvider.future);

        final result = container.read(analyticsConsentGateProvider);
        expect(
          result,
          isFalse,
          reason: 'Null consent scopes should fail-safe to no analytics',
        );
      });

      test('returns false when analytics scope is not present', () async {
        final mockService = _MockUserStateService();
        // User accepted health and terms, but NOT analytics
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms'});

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final result = container.read(analyticsConsentGateProvider);
        expect(
          result,
          isFalse,
          reason: 'Missing analytics scope should return false',
        );
      });

      test('returns true when analytics scope is present', () async {
        final mockService = _MockUserStateService();
        // User accepted health, terms, AND analytics
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms', ConsentScope.analytics.name});

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final result = container.read(analyticsConsentGateProvider);
        expect(
          result,
          isTrue,
          reason: 'Present analytics scope should return true',
        );
      });
    });

    group('analyticsConsentOptOutProvider', () {
      test('returns true (opt-out) when analytics consent is false', () async {
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms'}); // No analytics

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final result = container.read(analyticsConsentOptOutProvider);
        expect(
          result,
          isTrue,
          reason: 'No analytics consent = opt-out = true',
        );
      });

      test('returns false (opted-in) when analytics consent is true', () async {
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms', 'analytics'});

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final result = container.read(analyticsConsentOptOutProvider);
        expect(
          result,
          isFalse,
          reason: 'Analytics consent = opted-in = false (not opt-out)',
        );
      });
    });

    group('DebugAnalyticsRecorder integration', () {
      test('events are dropped when analytics consent is false', () async {
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms'}); // No analytics consent

        final recordedEvents = <String>[];

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
            // Override opt-out to use consent-based value
            analyticsOptOutProvider.overrideWith(
              (ref) => ref.watch(analyticsConsentOptOutProvider),
            ),
            // Track events via backend sink
            analyticsBackendSinkProvider.overrideWithValue(
              (name, _) => recordedEvents.add(name),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final recorder = container.read(analyticsRecorderProvider);
        recorder.recordEvent('test_event');

        expect(
          recordedEvents,
          isEmpty,
          reason: 'Events should be dropped when analytics consent is false',
        );
      });

      test('events flow when analytics consent is true', () async {
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({'health', 'terms', 'analytics'});

        final recordedEvents = <String>[];

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
            analyticsOptOutProvider.overrideWith(
              (ref) => ref.watch(analyticsConsentOptOutProvider),
            ),
            analyticsBackendSinkProvider.overrideWithValue(
              (name, _) => recordedEvents.add(name),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final recorder = container.read(analyticsRecorderProvider);
        recorder.recordEvent('test_event');

        expect(
          recordedEvents,
          contains('test_event'),
          reason: 'Events should flow when analytics consent is true',
        );
      });
    });

    group('UserStateService scope persistence', () {
      test('scopes are correctly persisted and retrieved', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);

        // Bind to a test user
        await service.bindUser('test-user-123');

        // Initially null
        expect(service.acceptedConsentScopesOrNull, isNull);

        // Persist scopes
        await service.setAcceptedConsentScopes({'health', 'terms', 'analytics'});

        // Retrieve scopes
        final scopes = service.acceptedConsentScopesOrNull;
        expect(scopes, isNotNull);
        expect(scopes, containsAll(['health', 'terms', 'analytics']));
      });

      test('scopes handle corrupted JSON gracefully', () async {
        SharedPreferences.setMockInitialValues({
          'u:test-user:accepted_consent_scopes_json': 'invalid json {{{',
        });
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        // Should return null on corrupted JSON (fail-safe)
        expect(service.acceptedConsentScopesOrNull, isNull);
      });
    });
  });
}
