// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_state.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Riverpod notifier for onboarding state management.

@ProviderFor(OnboardingNotifier)
const onboardingProvider = OnboardingNotifierProvider._();

/// Riverpod notifier for onboarding state management.
final class OnboardingNotifierProvider
    extends $NotifierProvider<OnboardingNotifier, OnboardingData> {
  /// Riverpod notifier for onboarding state management.
  const OnboardingNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingNotifierHash();

  @$internal
  @override
  OnboardingNotifier create() => OnboardingNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingData>(value),
    );
  }
}

String _$onboardingNotifierHash() =>
    r'eee47117d37e6587c1b0e5a675cf2f7d58ba3db8';

/// Riverpod notifier for onboarding state management.

abstract class _$OnboardingNotifier extends $Notifier<OnboardingData> {
  OnboardingData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<OnboardingData, OnboardingData>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<OnboardingData, OnboardingData>,
              OnboardingData,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
