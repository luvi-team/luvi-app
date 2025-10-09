import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

class WorkoutDetailStubScreen extends StatelessWidget {
  const WorkoutDetailStubScreen({super.key, required this.workoutId});

  final String workoutId;

  static const String route = '/workout/:id';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Workout',
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
      body: Center(
        child: Text(
          'Workout Detail (Stub)\nID: $workoutId',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: FontFamilies.figtree,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF6D6D6D),
          ),
        ),
      ),
    );
  }
}
