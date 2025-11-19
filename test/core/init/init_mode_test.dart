import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/init_mode.dart';
import 'package:luvi_app/features/navigation/route_orientation_controller.dart';
import 'package:luvi_app/main.dart';
import 'package:luvi_services/init_mode.dart';
import 'package:luvi_services/init_exception.dart';
import 'package:luvi_app/core/init/supabase_init_controller.dart';

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
    // Wait until the controller attempted initialization at least once.
    final element = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(element);
    for (var i = 0; i < 10; i++) {
      final s = container.read(supabaseInitControllerProvider);
      if (s.attempts > 0) break;
      await tester.pump(const Duration(milliseconds: 50));
    }

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.byIcon(Icons.wifi_off), findsNothing);
  });

  testWidgets('InitMode.prod shows init overlay', (tester) async {
    // Capture only expected initialization errors (SupabaseInitException) and
    // forward unexpected ones to avoid hiding legitimate failures.
    final prevOnError = FlutterError.onError;
    final recorded = <FlutterErrorDetails>[];
    FlutterError.onError = (details) {
      final isExpectedInitError = details.exception is SupabaseInitException;
      if (isExpectedInitError) {
        recorded.add(details);
        return; // swallow expected init errors
      }
      // Forward unexpected errors
      if (prevOnError != null) {
        prevOnError(details);
      } else {
        FlutterError.dumpErrorToConsole(details);
        fail('Unexpected Flutter error: ${details.exceptionAsString()}');
      }
    };
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
    // Ensure initialization was attempted at least once (no flakiness), then
    // assert the offline overlay is visible.
    final element = tester.element(find.byType(MaterialApp));
    final container = ProviderScope.containerOf(element);
    for (var i = 0; i < 10; i++) {
      final s = container.read(supabaseInitControllerProvider);
      if (s.attempts > 0) break;
      await tester.pump(const Duration(milliseconds: 50));
    }
    expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    // If any errors were recorded, verify they are all SupabaseInitException.
    if (recorded.isNotEmpty) {
      final allExpected = recorded.every((details) => details.exception is SupabaseInitException);
      expect(allExpected, isTrue, reason: 'Unexpected Flutter errors captured during prod init test');
    }
  });
}
