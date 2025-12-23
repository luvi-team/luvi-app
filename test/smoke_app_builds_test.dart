import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/init/supabase_deep_link_handler.dart';
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
    // Pump deep link timeout + buffer to allow handler to complete
    await tester.pump(
      SupabaseDeepLinkHandler.deepLinkTimeout + const Duration(seconds: 1),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
