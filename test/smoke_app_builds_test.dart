import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/navigation/route_orientation_controller.dart';
import 'package:luvi_app/main.dart';
import 'support/test_config.dart';

void main() {
  TestConfig.ensureInitialized();
  testWidgets('smoke test: LUVI app builds without crashing', (tester) async {
    final controller = RouteOrientationController(
      defaultOrientations: const [DeviceOrientation.portraitUp],
      setter: (orientations) async {},
    );

    await tester.pumpWidget(
      ProviderScope(child: MyApp(orientationController: controller)),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
