import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_services/init_mode.dart';

// Default: Production mode. Tests should override this provider to InitMode.test
// in their ProviderScope to disable retries/overlays and network initialization.
final initModeProvider = Provider<InitMode>((_) => InitMode.prod);

// Example (in tests): override provider to InitMode.test
// 
// testWidgets('uses test init mode', (tester) async {
//   await tester.pumpWidget(
//     ProviderScope(
//       overrides: [
//         // Either override with value...
//         initModeProvider.overrideWithValue(InitMode.test),
//         // ...or with a factory (Riverpod 2.x):
//         // initModeProvider.overrideWith((ref) => InitMode.test),
//       ],
//       child: MyApp(),
//     ),
//   );
//   // assertions ...
// });
