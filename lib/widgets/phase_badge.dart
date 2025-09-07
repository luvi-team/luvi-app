import 'package:flutter/material.dart';
import '../models/cycle.dart';

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
    return Text(info.phaseOn(date), key: const Key('phase-text'));
  }
}