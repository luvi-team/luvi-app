// ignore_for_file: constant_identifier_names
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart';

part 'consent02_state.g.dart';

enum ConsentScope {
  terms,
  health_processing,
  ai_journal,
  analytics,
  marketing,
  model_training,
}

const requiredScopes = {
  ConsentScope.terms,
  ConsentScope.health_processing,
  ConsentScope.ai_journal,
};

@immutable
class Consent02State {
  final Map<ConsentScope, bool> choices;
  const Consent02State(this.choices);
  bool get requiredAccepted => requiredScopes.every((s) => choices[s] == true);
  bool get allOptionalSelected => ConsentScope.values
      .where((s) => !requiredScopes.contains(s))
      .every((s) => choices[s] == true);
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

  void selectAllOptional() {
    final m = {...state.choices};
    for (final s in ConsentScope.values) {
      if (!requiredScopes.contains(s)) m[s] = true;
    }
    state = state.copyWith(choices: m);
  }

  void clearAllOptional() {
    final m = {...state.choices};
    for (final s in ConsentScope.values) {
      if (!requiredScopes.contains(s)) m[s] = false;
    }
    state = state.copyWith(choices: m);
  }
}
