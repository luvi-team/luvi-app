import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'clock.dart';

/// Provider for Clock abstraction.
///
/// Override in tests with FixedClock for deterministic behavior:
/// ```dart
/// ProviderScope(
///   overrides: [clockProvider.overrideWithValue(FixedClock.at(2025, 12, 15))],
///   child: ...
/// )
/// ```
final clockProvider = Provider<Clock>((_) => const SystemClock());
