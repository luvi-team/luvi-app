import 'package:flutter/material.dart';

// Standalone demo moved out of lib/; intentionally not wired to app services.
class EmailPreferencesDemo extends StatelessWidget {
  const EmailPreferencesDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Email Preferences Demo')),
      body: const Center(child: Text('Standalone demo placeholder')),
    );
  }
}
