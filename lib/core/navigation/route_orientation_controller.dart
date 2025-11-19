import 'dart:async';
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

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    final name = route.settings.name;
    unawaited(
      _controller.applyForRoute(name).catchError((error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'route_orientation_controller',
          context: ErrorDescription('applyForRoute(didPush, name=$name)'),
        ));
      }),
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    final name = newRoute?.settings.name;
    unawaited(
      _controller.applyForRoute(name).catchError((error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'route_orientation_controller',
          context: ErrorDescription('applyForRoute(didReplace, name=$name)'),
        ));
      }),
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    final name = previousRoute?.settings.name;
    unawaited(
      _controller.applyForRoute(name).catchError((error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'route_orientation_controller',
          context: ErrorDescription('applyForRoute(didPop, name=$name)'),
        ));
      }),
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    final name = previousRoute?.settings.name;
    unawaited(
      _controller.applyForRoute(name).catchError((error, stack) {
        FlutterError.reportError(FlutterErrorDetails(
          exception: error,
          stack: stack,
          library: 'route_orientation_controller',
          context: ErrorDescription('applyForRoute(didRemove, name=$name)'),
        ));
      }),
    );
  }
}
