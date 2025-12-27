import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configures test view size (1080x2340, 1.0 dpr).
/// Returns teardown function to reset view settings.
///
/// Usage:
/// ```dart
/// testWidgets('my test', (tester) async {
///   addTearDown(configureTestView(tester));
///   // ... test code
/// });
/// ```
void Function() configureTestView(WidgetTester tester) {
  final view = tester.view;
  view.physicalSize = const Size(1080, 2340);
  view.devicePixelRatio = 1.0;
  return () {
    view.resetPhysicalSize();
    view.resetDevicePixelRatio();
  };
}
