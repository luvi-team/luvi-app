// ignore_for_file: constant_identifier_names
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:luvi_app/features/consent/domain/consent_types.dart';

// Re-export to keep existing import sites working.
export 'package:luvi_app/features/consent/domain/consent_types.dart'
    show ConsentScope, kRequiredConsentScopes, kVisibleOptionalScopes;

part 'consent02_state.g.dart';
@immutable
class Consent02State {
  final Map<ConsentScope, bool> choices;
  const Consent02State(this.choices);
  bool get requiredAccepted =>
      kRequiredConsentScopes.every((s) => choices[s] == true);
  bool get allOptionalSelected => ConsentScope.values
      .where((s) => !kRequiredConsentScopes.contains(s))
      .every((s) => choices[s] == true);

  /// True if all VISIBLE optional scopes are selected (DSGVO-konform).
  /// Used for UI toggle button state.
  bool get allVisibleOptionalSelected =>
      kVisibleOptionalScopes.every((s) => choices[s] == true);

  Consent02State copyWith({Map<ConsentScope, bool>? choices}) =>
      Consent02State(choices ?? this.choices);
}

@riverpod
class Consent02Notifier extends _$Consent02Notifier {
  @override
  Consent02State build() =>
      Consent02State({for (final s in ConsentScope.values) s: false});

  void toggle(ConsentScope s) => state = state.copyWith(
    choices: {...state.choices, s: !(state.choices[s] ?? false)},
  );

  /// Selects only the optional scopes that are VISIBLE in the MVP UI.
  /// DSGVO: Does NOT set hidden scopes (ai_journal, marketing, model_training).
  void selectAllVisibleOptional() {
    final m = {...state.choices};
    for (final s in kVisibleOptionalScopes) {
      m[s] = true;
    }
    state = state.copyWith(choices: m);
  }

  /// Atomically accepts all required + visible optional scopes.
  /// Use this instead of multiple toggle() calls to avoid race conditions.
  void acceptAll() {
    final m = {...state.choices};
    // Required scopes
    for (final s in kRequiredConsentScopes) {
      m[s] = true;
    }
    // Visible optional scopes (DSGVO-konform)
    for (final s in kVisibleOptionalScopes) {
      m[s] = true;
    }
    state = state.copyWith(choices: m);
  }

  void clearAllOptional() {
    final m = {...state.choices};
    for (final s in ConsentScope.values) {
      if (!kRequiredConsentScopes.contains(s)) m[s] = false;
    }
    state = state.copyWith(choices: m);
  }
}
