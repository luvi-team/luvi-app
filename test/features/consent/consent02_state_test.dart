import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/state/consent02_state.dart';

void main() {
  group('Consent02Notifier', () {
    test('initial state: all false', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final state = container.read(consent02Provider);
      for (final s in ConsentScope.values) {
        expect(state.choices[s], isFalse);
      }
      expect(state.requiredAccepted, isFalse);
      expect(state.allOptionalSelected, isFalse);
    });

    test('toggle(terms) flips value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(consent02Provider.notifier);
      notifier.toggle(ConsentScope.terms);
      final state = container.read(consent02Provider);
      expect(state.choices[ConsentScope.terms], isTrue);
    });

    test('requiredAccepted only true when all required scopes are true', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(consent02Provider.notifier);

      // Initially false
      expect(container.read(consent02Provider).requiredAccepted, isFalse);

      // Only terms -> still false
      notifier.toggle(ConsentScope.terms);
      expect(container.read(consent02Provider).requiredAccepted, isFalse);


      // Terms + health -> now true (AI journal is optional)
      notifier.toggle(ConsentScope.health_processing);
      expect(container.read(consent02Provider).requiredAccepted, isTrue);
    });

    test('selectAllOptional sets optional true, required unchanged', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(consent02Provider.notifier);

      // Ensure required are false to start
      final before = container.read(consent02Provider);
      expect(before.choices[ConsentScope.terms], isFalse);
      expect(before.choices[ConsentScope.health_processing], isFalse);

      notifier.selectAllOptional();

      final state = container.read(consent02Provider);
      expect(state.choices[ConsentScope.analytics], isTrue);
      expect(state.choices[ConsentScope.marketing], isTrue);
      expect(state.choices[ConsentScope.model_training], isTrue);
      expect(state.choices[ConsentScope.ai_journal], isTrue);

      // Required unchanged
      expect(state.choices[ConsentScope.terms], isFalse);
      expect(state.choices[ConsentScope.health_processing], isFalse);
    });
  });
}
