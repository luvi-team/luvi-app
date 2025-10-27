// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_state_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(userStateService)
const userStateServiceProvider = UserStateServiceProvider._();

final class UserStateServiceProvider
    extends
        $FunctionalProvider<
          AsyncValue<UserStateService>,
          UserStateService,
          FutureOr<UserStateService>
        >
    with $FutureModifier<UserStateService>, $FutureProvider<UserStateService> {
  const UserStateServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'userStateServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$userStateServiceHash();

  @$internal
  @override
  $FutureProviderElement<UserStateService> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<UserStateService> create(Ref ref) {
    return userStateService(ref);
  }
}

String _$userStateServiceHash() => r'29460d76b3f195a73efe8bef14fb1c1e77c2353c';
