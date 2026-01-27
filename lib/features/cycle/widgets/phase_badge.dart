import 'package:flutter/material.dart';
import 'package:luvi_app/core/config/test_keys.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';

class PhaseBadge extends StatelessWidget {
  final CycleInfo info;
  final DateTime date;
  final bool consentGiven;

  const PhaseBadge({
    super.key,
    required this.info,
    required this.date,
    required this.consentGiven,
  });

  @override
  Widget build(BuildContext c) {
    if (!consentGiven) return const SizedBox.shrink();
    return Text(info.phaseOn(date), key: const Key(TestKeys.phaseText));
  }
}
