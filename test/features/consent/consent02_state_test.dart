import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';

void main() {
  group('Consent02Notifier', () {
    test('initial state: all false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(consent02NotifierProvider);
      for (final s in ConsentScope.values) {
        expect(state.choices[s], isFalse);
      }
      expect(state.requiredAccepted, isFalse);
      expect(state.allOptionalSelected, isFalse);
    });

    test('toggle(terms) flips value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(consent02NotifierProvider.notifier);
      notifier.toggle(ConsentScope.terms);
      final state = container.read(consent02NotifierProvider);
      expect(state.choices[ConsentScope.terms], isTrue);
    });

    test(
      'requiredAccepted only true when terms & health_processing are true',
      () {
        final container = ProviderContainer();
        addTearDown(container.dispose);
        final notifier = container.read(consent02NotifierProvider.notifier);

        // Initially false
        expect(
          container.read(consent02NotifierProvider).requiredAccepted,
          isFalse,
        );

        // Only terms -> still false
        notifier.toggle(ConsentScope.terms);
        expect(
          container.read(consent02NotifierProvider).requiredAccepted,
          isFalse,
        );

        // Both required -> true
        notifier.toggle(ConsentScope.health_processing);
        expect(
          container.read(consent02NotifierProvider).requiredAccepted,
          isTrue,
        );
      },
    );

    test('selectAllOptional sets optional true, required unchanged', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(consent02NotifierProvider.notifier);

      // Ensure required are false to start
      final before = container.read(consent02NotifierProvider);
      expect(before.choices[ConsentScope.terms], isFalse);
      expect(before.choices[ConsentScope.health_processing], isFalse);

      notifier.selectAllOptional();

      final state = container.read(consent02NotifierProvider);
      expect(state.choices[ConsentScope.analytics], isTrue);
      expect(state.choices[ConsentScope.marketing], isTrue);
      expect(state.choices[ConsentScope.model_training], isTrue);

      // Required unchanged
      expect(state.choices[ConsentScope.terms], isFalse);
      expect(state.choices[ConsentScope.health_processing], isFalse);
    });
  });
}
