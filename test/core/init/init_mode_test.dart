import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/features/navigation/route_orientation_controller.dart';
import 'package:luvi_app/main.dart';
import 'package:luvi_services/init_mode.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('InitMode.test bypasses init overlay', (tester) async {
    // Ensure bridge reflects test mode and provider override also set to test.
    final prev = InitModeBridge.resolve;
    InitModeBridge.resolve = () => InitMode.test;
    addTearDown(() {
      InitModeBridge.resolve = prev;
    });
    final controller = RouteOrientationController(
      defaultOrientations: const [DeviceOrientation.portraitUp],
      setter: (orientations) async {},
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProviderScope(
          overrides: [initModeProvider.overrideWithValue(InitMode.test)],
          child: MyApp(orientationController: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsNothing);
  });

  testWidgets('InitMode.prod shows init overlay', (tester) async {
    // Swallow framework error reporting for this test: we intentionally run in
    // prod mode without valid env to exercise the overlay. Initialization will
    // report errors via FlutterError which would normally fail the test.
    final prevOnError = FlutterError.onError;
    FlutterError.onError = (details) {};
    addTearDown(() { FlutterError.onError = prevOnError; });
    // Force bridge to prod before app bootstrap so MyAppWrapper binds bridge
    // from provider rather than keeping test short-circuit.
    final prev = InitModeBridge.resolve;
    InitModeBridge.resolve = () => InitMode.prod;
    addTearDown(() {
      InitModeBridge.resolve = prev;
    });
    final controller = RouteOrientationController(
      defaultOrientations: const [DeviceOrientation.portraitUp],
      setter: (orientations) async {},
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: ProviderScope(
          overrides: [initModeProvider.overrideWithValue(InitMode.prod)],
          child: MyApp(orientationController: controller),
        ),
      ),
    );
    await tester.pumpAndSettle();
    
    // Overlay renders a WiFi off icon when not yet initialized.
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
  });
}
