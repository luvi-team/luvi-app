// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_state_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(deviceStateService)
const deviceStateServiceProvider = DeviceStateServiceProvider._();

final class DeviceStateServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<DeviceStateService>,
          DeviceStateService,
          FutureOr<DeviceStateService>
        >
    with
        $FutureModifier<DeviceStateService>,
        $FutureProvider<DeviceStateService> {
  const DeviceStateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deviceStateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deviceStateServiceHash();

  @$internal
  @override
  $FutureProviderElement<DeviceStateService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<DeviceStateService> create(Ref ref) {
    return deviceStateService(ref);
  }
}

String _$deviceStateServiceHash() =>
    r'a34bae5d7f83543c6738f92d31a157d68350c01c';
