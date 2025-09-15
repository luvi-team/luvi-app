import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';

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
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Deine E-Mail',
                ),
                onChanged: (v) => ref.read(loginProvider.notifier).setEmail(v),
              ),
              const SizedBox(height: 16),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Dein Passwort',
                  errorText: ref.watch(loginProvider).error,
                  suffixIcon: const Icon(Icons.visibility_off),
                ),
                onChanged: (v) =>
                    ref.read(loginProvider.notifier).setPassword(v),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: ref.watch(loginProvider).isValid
                    ? () {
                        // TODO: Supabase Sign-In
                      }
                    : null,
                child: const Text('Anmelden'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
