import 'dart:async' show Future, unawaited;
// Removed unused 'meta' import to satisfy analyzer and avoid extra dependency.

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef OrientationSetter = Future<void> Function(
  List<DeviceOrientation> orientations,
);

/// Centralizes app-wide orientation preferences and applies overrides per route.
class RouteOrientationController {
  RouteOrientationController({
    required List<DeviceOrientation> defaultOrientations,
    Map<String, List<DeviceOrientation>> routeOverrides =
        const <String, List<DeviceOrientation>>{},
    OrientationSetter? setter,
  })  : assert(
          defaultOrientations.isNotEmpty,
          'defaultOrientations must not be empty',
        ),
        assert(
          routeOverrides.values.every((list) => list.isNotEmpty),
          'All orientation lists in routeOverrides must be non-empty',
        ),
        defaultOrientations = List.unmodifiable(defaultOrientations),
        routeOverrides = Map.unmodifiable(
          routeOverrides.map(
            (key, value) => MapEntry(
                key,
                List<DeviceOrientation>.unmodifiable(value),
            ),
          ),
        ),
        _setter = setter ?? SystemChrome.setPreferredOrientations;

  /// Default orientations applied when no explicit route override exists.
  final List<DeviceOrientation> defaultOrientations;

  /// Map of route names to orientation overrides. Each entry is stored as an unmodifiable list.
  final Map<String, List<DeviceOrientation>> routeOverrides;

  final OrientationSetter _setter;

  /// Navigator observer that applies orientation overrides as routes change.
  /// Must be registered with the app's `Navigator`/`MaterialApp` so callbacks
  /// fire (e.g. `MaterialApp(navigatorObservers: [controller.navigatorObserver], ...)`).
  late final NavigatorObserver navigatorObserver =
      _RouteOrientationObserver(this);

  Future<void> applyDefault() => _setter(defaultOrientations);

  Future<void> applyForRoute(String? routeName) =>
      _setter(routeOverrides[routeName] ?? defaultOrientations);
}

class _RouteOrientationObserver extends NavigatorObserver {
  _RouteOrientationObserver(this._controller);

  final RouteOrientationController _controller;

  void _guardedApply(Route<dynamic>? route, String source) {
    final routeName = route?.settings.name;
    // Skip unnamed routes - they inherit the current orientation
    if (routeName == null) return;
    unawaited(
      _controller.applyForRoute(routeName).catchError((error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'route_orientation_controller',
          context: ErrorDescription(
            'Failed to apply orientation for "$routeName" on $source',
          ),
        ));
      }),
    );
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _guardedApply(route, 'push');
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _guardedApply(newRoute, 'replace');
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _guardedApply(previousRoute, 'pop');
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _guardedApply(previousRoute, 'remove');
  }
}
