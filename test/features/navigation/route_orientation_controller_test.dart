import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/navigation/route_orientation_controller.dart';

class _FakeOrientationSetter {
  final List<List<DeviceOrientation>> calls = [];

  Future<void> call(List<DeviceOrientation> orientations) async {
    calls.add(List.unmodifiable(orientations));
  }
}

class _TestPageRoute extends PageRoute<void> {
  _TestPageRoute(String? name)
      : super(settings: RouteSettings(name: name));

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration.zero;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) =>
      const SizedBox.shrink();

  @override
  bool get fullscreenDialog => false;
}

void main() {
  test('applyDefault forwards to setter with default orientations', () async {
    final fakeSetter = _FakeOrientationSetter();
    final controller = RouteOrientationController(
      defaultOrientations: const [DeviceOrientation.portraitUp],
      setter: fakeSetter.call,
    );

    await controller.applyDefault();

    expect(
      fakeSetter.calls,
      [
        [DeviceOrientation.portraitUp],
      ],
    );
  });

  testWidgets('navigator observer applies overrides per route', (tester) async {
    final fakeSetter = _FakeOrientationSetter();
    final controller = RouteOrientationController(
      defaultOrientations: const [DeviceOrientation.portraitUp],
      routeOverrides: const {
        'landscape': [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
      },
      setter: fakeSetter.call,
    );

    final observer = controller.navigatorObserver;
    final defaultRoute = _TestPageRoute('home');
    final landscapeRoute = _TestPageRoute('landscape');

    observer.didPush(defaultRoute, null);
    observer.didPush(landscapeRoute, defaultRoute);
    observer.didPop(landscapeRoute, defaultRoute);

    await tester.pump(); // flush microtasks

    expect(
      fakeSetter.calls,
      [
        [DeviceOrientation.portraitUp],
        [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight,
        ],
        [DeviceOrientation.portraitUp],
      ],
    );
  });
}
