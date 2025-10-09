import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

/// Temporary placeholder for the cycle overview route.
class CycleOverviewStubScreen extends StatelessWidget {
  static const String routeName = '/zyklus';

  const CycleOverviewStubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Zyklus',
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF030401),
      ),
      backgroundColor: Colors.white,
      body: const Center(
        child: Text(
          'Cycle overview (Stub)',
          style: TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6D6D6D),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
