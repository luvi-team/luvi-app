import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Minimal LoginScreen aligned with current theme and tokens usage.
/// Uses Theme.of(context).textTheme for typography, consistent with app_theme.dart.
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Willkommen zurück 💜',
                style: t.textTheme.headlineMedium,
                textAlign: TextAlign.left,
                semanticsLabel: 'Login Überschrift',
              ),
              const SizedBox(height: 24),
              // TODO: InputFields + Error/Fill States → nächste Iteration
              ElevatedButton(
                onPressed: () {
                  // TODO: Hook up auth next iteration
                },
                child: const Text('Anmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
