import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_services/init_mode.dart';

// Default: Production mode. Tests should override this provider to InitMode.test
// in their ProviderScope to disable retries/overlays and network initialization.
final initModeProvider = Provider<InitMode>((_) => InitMode.prod);

