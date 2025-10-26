import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef OrientationSetter = Future<void> Function(
  List<DeviceOrientation> orientations,
);

/// Centralizes app-wide orientation preferences and applies overrides per route.
class RouteOrientationController {
  RouteOrientationController({
    required List<DeviceOrientation> defaultOrientations,
    Map<String, List<DeviceOrientation>> routeOverrides = const {},
    OrientationSetter? setter,
  })  : defaultOrientations = List.unmodifiable(defaultOrientations),
        routeOverrides = Map.unmodifiable(
          routeOverrides.map<String, List<DeviceOrientation>>(
            (key, value) => MapEntry<String, List<DeviceOrientation>>(
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
    unawaited(_controller.applyForRoute(route.settings.name));
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    unawaited(_controller.applyForRoute(newRoute?.settings.name));
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    unawaited(_controller.applyForRoute(previousRoute?.settings.name));
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    unawaited(_controller.applyForRoute(previousRoute?.settings.name));
  }
}
