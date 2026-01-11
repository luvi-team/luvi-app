// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'consent02_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Consent02Notifier)
const consent02Provider = Consent02NotifierProvider._();

final class Consent02NotifierProvider
    extends $NotifierProvider<Consent02Notifier, Consent02State> {
  const Consent02NotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'consent02Provider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$consent02NotifierHash();

  @$internal
  @override
  Consent02Notifier create() => Consent02Notifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Consent02State value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Consent02State>(value),
    );
  }
}

String _$consent02NotifierHash() => r'62565762a22c79b0531f40d58bc71209c2bac47a';

abstract class _$Consent02Notifier extends $Notifier<Consent02State> {
  Consent02State build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<Consent02State, Consent02State>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Consent02State, Consent02State>,
              Consent02State,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
