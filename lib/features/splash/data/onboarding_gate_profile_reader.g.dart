// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_gate_profile_reader.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(onboardingGateProfileReader)
const onboardingGateProfileReaderProvider =
    OnboardingGateProfileReaderProvider._();

final class OnboardingGateProfileReaderProvider
    extends
        $FunctionalProvider<
          OnboardingGateProfileReader,
          OnboardingGateProfileReader,
          OnboardingGateProfileReader
        >
    with $Provider<OnboardingGateProfileReader> {
  const OnboardingGateProfileReaderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingGateProfileReaderProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingGateProfileReaderHash();

  @$internal
  @override
  $ProviderElement<OnboardingGateProfileReader> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  OnboardingGateProfileReader create(Ref ref) {
    return onboardingGateProfileReader(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(OnboardingGateProfileReader value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<OnboardingGateProfileReader>(value),
    );
  }
}

String _$onboardingGateProfileReaderHash() =>
    r'1f7338faec2c75fe2551abeff14071eeafc75e04';
