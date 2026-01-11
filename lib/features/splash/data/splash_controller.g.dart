// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'splash_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for splash screen gate orchestration.
///
/// Handles the sequential gate checks:
/// 1. Welcome gate (device-local)
/// 2. Auth gate (Supabase authentication)
/// 3. User state + Consent gate (with cache sync)
/// 4. Onboarding gate (with race-retry)
///
/// No BuildContext, no navigation - UI listens to state and navigates.

@ProviderFor(SplashController)
const splashControllerProvider = SplashControllerProvider._();

/// Controller for splash screen gate orchestration.
///
/// Handles the sequential gate checks:
/// 1. Welcome gate (device-local)
/// 2. Auth gate (Supabase authentication)
/// 3. User state + Consent gate (with cache sync)
/// 4. Onboarding gate (with race-retry)
///
/// No BuildContext, no navigation - UI listens to state and navigates.
final class SplashControllerProvider
    extends $NotifierProvider<SplashController, SplashState> {
  /// Controller for splash screen gate orchestration.
  ///
  /// Handles the sequential gate checks:
  /// 1. Welcome gate (device-local)
  /// 2. Auth gate (Supabase authentication)
  /// 3. User state + Consent gate (with cache sync)
  /// 4. Onboarding gate (with race-retry)
  ///
  /// No BuildContext, no navigation - UI listens to state and navigates.
  const SplashControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'splashControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$splashControllerHash();

  @$internal
  @override
  SplashController create() => SplashController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SplashState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SplashState>(value),
    );
  }
}

String _$splashControllerHash() => r'ecc4184752af044b56f0e3ec7882fd9e6a992f63';

/// Controller for splash screen gate orchestration.
///
/// Handles the sequential gate checks:
/// 1. Welcome gate (device-local)
/// 2. Auth gate (Supabase authentication)
/// 3. User state + Consent gate (with cache sync)
/// 4. Onboarding gate (with race-retry)
///
/// No BuildContext, no navigation - UI listens to state and navigates.

abstract class _$SplashController extends $Notifier<SplashState> {
  SplashState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SplashState, SplashState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SplashState, SplashState>,
              SplashState,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}
