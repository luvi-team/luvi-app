// Benchmark harness for compute_cycle_info (CycleInfo.phaseOn)
// Usage:
//   dart run tools/perf/compute_cycle_info_bench.dart --samples 10000 --warmup 100 --json docs/perf/compute_cycle_info/<DATE>.json

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:luvi_app/features/cycle/domain/cycle.dart';

Future<void> main(List<String> args) async {
  final parsed = _Args.parse(args);
  final samples = parsed.samples;
  final warmup = parsed.warmup;
  final jsonOut = parsed.jsonOut;

  // Build a representative input set across typical ranges
  final lastPeriod = DateTime(2025, 1, 1);
  final cycleLengths = [21, 28, 35];
  final periodDurations = [4, 5, 7];
  final nowBase = DateTime(2025, 2, 1);
  final inputs = <_Case>[];
  for (final cl in cycleLengths) {
    for (final pd in periodDurations) {
      for (var d = 0; d < cl; d++) {
        inputs.add(_Case(
          info: CycleInfo(
            lastPeriod: lastPeriod,
            cycleLength: cl,
            periodDuration: pd,
          ),
          now: nowBase.add(Duration(days: d)),
        ));
      }
    }
  }

  final watch = Stopwatch();
  // Warmup
  var wi = 0;
  for (var i = 0; i < warmup; i++) {
    final c = inputs[wi++ % inputs.length];
    watch
      ..reset()
      ..start();
    c.info.phaseOn(c.now);
    watch.stop();
  }

  // Samples
  final durations = List<int>.filled(samples, 0); // microseconds
  var si = 0;
  for (var i = 0; i < samples; i++) {
    final c = inputs[si++ % inputs.length];
    watch
      ..reset()
      ..start();
    c.info.phaseOn(c.now);
    watch.stop();
    durations[i] = watch.elapsedMicroseconds;
  }

  durations.sort();
  double msAtPercentile(double p) {
    final n = durations.length;
    final idx = (p * n).ceil() - 1;
    final clamped = idx.clamp(0, n - 1);
    return durations[clamped] / 1000.0;
  }

  final p50 = msAtPercentile(0.50);
  final p95 = msAtPercentile(0.95);
  final p99 = msAtPercentile(0.99);

  final device = await _collectDevice();
  final build = await _collectBuild();
  final artifact = {
    'timestamp': DateTime.now().toIso8601String(),
    'device': device,
    'build': build,
    'warmup': warmup,
    'samples': samples,
    'p50': p50,
    'p95': p95,
    'p99': p99,
    'deviations': <String, Object?>{},
  };

  final encoder = const JsonEncoder.withIndent('  ');
  final out = encoder.convert(artifact);
  if (jsonOut != null && jsonOut.isNotEmpty) {
    final file = File(jsonOut);
    await file.parent.create(recursive: true);
    await file.writeAsString(out);
    stdout.writeln('Wrote $jsonOut');
  } else {
    stdout.writeln(out);
  }
}

class _Case {
  final CycleInfo info;
  final DateTime now;
  _Case({required this.info, required this.now});
}

class _Args {
  final int samples;
  final int warmup;
  final String? jsonOut;
  _Args({required this.samples, required this.warmup, required this.jsonOut});

  static _Args parse(List<String> args) {
    var samples = 10000;
    var warmup = 100;
    String? jsonOut;
    for (var i = 0; i < args.length; i++) {
      final a = args[i];
      if (a == '--samples' && i + 1 < args.length) {
        samples = int.tryParse(args[++i]) ?? samples;
      } else if (a == '--warmup' && i + 1 < args.length) {
        warmup = int.tryParse(args[++i]) ?? warmup;
      } else if (a == '--json' && i + 1 < args.length) {
        jsonOut = args[++i];
      }
    }
    return _Args(samples: samples, warmup: warmup, jsonOut: jsonOut);
  }
}

Future<Map<String, Object?>> _collectDevice() async {
  final os = Platform.operatingSystem;
  final osVersion = Platform.operatingSystemVersion;
  String? model;
  String? cpu;
  String? arch;
  String? memory;

  arch = _try(() => Platform.version.split(' ').last);

  if (Platform.isMacOS) {
    model = await _tryAsync(() async =>
        (await Process.run('sysctl', ['-n', 'hw.model'])).stdout.toString().trim());
    cpu = await _tryAsync(() async => (await Process.run(
          'sysctl',
          ['-n', 'machdep.cpu.brand_string'],
        ))
            .stdout
            .toString()
            .trim());
    final memBytes = await _tryAsync(() async =>
        (await Process.run('sysctl', ['-n', 'hw.memsize']))
            .stdout
            .toString()
            .trim());
    if (memBytes != null && memBytes.isNotEmpty) {
      final n = int.tryParse(memBytes);
      if (n != null && n > 0) {
        memory = '${(n / (1024 * 1024 * 1024)).toStringAsFixed(0)} GB';
      }
    }
  }

  return <String, Object?>{
    'os': os,
    'osVersion': osVersion,
    if (model != null) 'model': model,
    if (cpu != null) 'cpu': cpu,
    if (arch != null) 'arch': arch,
    if (memory != null) 'memory': memory,
  };
}

Future<Map<String, Object?>> _collectBuild() async {
  String? flutterVersion;
  String? dartVersion;
  String? buildMode;

  // Try to read flutter version (machine-readable) if available
  try {
    final res = await Process.run('flutter', ['--version', '--machine']);
    if (res.exitCode == 0 && (res.stdout as String).isNotEmpty) {
      final data = jsonDecode(res.stdout as String) as Map<String, dynamic>;
      flutterVersion = data['flutterVersion']?.toString();
      dartVersion = data['dartSdkVersion']?.toString();
    }
  } catch (_) {
    // ignore
  }

  // Fallback Dart version
  dartVersion ??= Platform.version.split(' ').first;
  buildMode = const bool.fromEnvironment('dart.vm.product') ? 'release' : 'jit';

  return <String, Object?>{
    if (flutterVersion != null) 'flutter': flutterVersion,
    'dart': dartVersion,
    'mode': buildMode,
  };
}

T? _try<T>(T Function() fn) {
  try {
    return fn();
  } catch (_) {
    return null;
  }
}

Future<T?> _tryAsync<T>(Future<T> Function() fn) async {
  try {
    return await fn();
  } catch (_) {
    return null;
  }
}
