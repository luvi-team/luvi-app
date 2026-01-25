import 'dart:async';

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
      test(
        'returns false when UserStateService is loading',
        () {
          final completer = Completer<UserStateService>(); // Use Completer
          final container = ProviderContainer(
            overrides: [
              // Simulate loading state by not providing a value
              userStateServiceProvider.overrideWith(
                (ref) => completer.future, // Return the incomplete future
              ),
            ],
          );
          addTearDown(container.dispose);

          // Synchronous read - provider MUST handle loading state instantly
          // If this blocks, the provider implementation is broken
          final result = container.read(analyticsConsentGateProvider);
          expect(
            result,
            isFalse,
            reason: 'Loading state should fail-safe to no analytics',
          );
        },
        timeout: Timeout(Duration(milliseconds: 500)), // Fail-fast guard
      );

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
            .thenReturn({ConsentScope.health_processing.name, ConsentScope.terms.name});

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
            .thenReturn({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

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
            .thenReturn({ConsentScope.health_processing.name, ConsentScope.terms.name}); // No analytics

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
            .thenReturn({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

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
            .thenReturn({ConsentScope.health_processing.name, ConsentScope.terms.name}); // No analytics consent

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
            .thenReturn({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

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

      test('blocks username property key even when consent is true', () async {
        // Privacy gate: username is classified as PII (2026-01 governance fix).
        // Events containing username property key must never reach the backend.
        final mockService = _MockUserStateService();
        when(() => mockService.acceptedConsentScopesOrNull)
            .thenReturn({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

        final recordedEvents = <(String, Map<String, Object?>)>[];

        final container = ProviderContainer(
          overrides: [
            userStateServiceProvider
                .overrideWith((ref) => Future.value(mockService)),
            analyticsOptOutProvider.overrideWith(
              (ref) => ref.watch(analyticsConsentOptOutProvider),
            ),
            analyticsBackendSinkProvider.overrideWithValue(
              (name, props) => recordedEvents.add((name, props)),
            ),
          ],
        );
        addTearDown(container.dispose);

        await container.read(userStateServiceProvider.future);

        final recorder = container.read(analyticsRecorderProvider);

        // Attempt to record event with username property - should be blocked
        recorder.recordEvent(
          'profile_viewed',
          properties: {'username': 'alice', 'screen': 'profile'},
        );

        expect(
          recordedEvents,
          isEmpty,
          reason: 'Events with username property must be blocked as PII',
        );

        // Verify that events without PII keys still flow
        recorder.recordEvent(
          'screen_viewed',
          properties: {'screen': 'home'},
        );

        expect(
          recordedEvents,
          hasLength(1),
          reason: 'Clean events should still flow',
        );
        expect(recordedEvents.first.$1, 'screen_viewed');
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
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

        // Retrieve scopes
        final scopes = service.acceptedConsentScopesOrNull;
        expect(scopes, isNotNull);
        expect(
          scopes,
          containsAll([
            ConsentScope.health_processing.name,
            ConsentScope.terms.name,
            ConsentScope.analytics.name,
          ]),
        );
      });

      test('scopes can be updated (add analytics)', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user-update');

        // Initial: only required scopes
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
        });

        expect(service.acceptedConsentScopesOrNull, isNotNull);
        expect(
          service.acceptedConsentScopesOrNull,
          isNot(contains(ConsentScope.analytics.name)),
        );

        // Update: add analytics consent
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

        final scopes = service.acceptedConsentScopesOrNull;
        expect(scopes, contains(ConsentScope.analytics.name));
      });

      test('scopes can be reduced (remove analytics)', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user-remove');

        // Initial: full scopes including analytics
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
          ConsentScope.analytics.name,
        });

        expect(
          service.acceptedConsentScopesOrNull,
          contains(ConsentScope.analytics.name),
        );

        // User revokes analytics consent
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.terms.name,
        });

        final scopes = service.acceptedConsentScopesOrNull;
        expect(scopes, isNotNull);
        expect(
          scopes,
          containsAll([
            ConsentScope.health_processing.name,
            ConsentScope.terms.name,
          ]),
        );
        expect(scopes, isNot(contains(ConsentScope.analytics.name)));
      });

      test('scopes can be cleared to empty set', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user-clear');

        // Set initial scopes
        await service.setAcceptedConsentScopes({
          ConsentScope.health_processing.name,
          ConsentScope.analytics.name,
        });

        expect(service.acceptedConsentScopesOrNull, isNotEmpty);

        // Clear all scopes
        await service.setAcceptedConsentScopes({});

        final scopes = service.acceptedConsentScopesOrNull;
        expect(scopes, isNotNull);
        expect(scopes, isEmpty);
      });

      test('scopes handle corrupted JSON gracefully', () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final service = UserStateService(prefs: prefs);
        await service.bindUser('test-user');

        // Set valid scopes first (creates the key via public API)
        await service.setAcceptedConsentScopes({'health_processing', 'terms'});

        // Use test accessor to get the actual key
        final scopesKey = service.acceptedConsentScopesKeyForTesting;
        if (scopesKey == null) {
          fail('User not bound - acceptedConsentScopesKeyForTesting is null');
        }

        // Corrupt the JSON
        await prefs.setString(scopesKey, 'invalid json {{{');

        // Should return null on corrupted JSON (fail-safe)
        expect(service.acceptedConsentScopesOrNull, isNull);
      });
    });
  });
}
