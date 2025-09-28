import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Entry screen shown after consent flow but before sign up/login.
class AuthEntryScreen extends ConsumerWidget {
  const AuthEntryScreen({super.key});

  static const routeName = '/auth/entry';
  static const _heroAssetPath = 'assets/images/auth/hero_login_default_00.png';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    return Scaffold(
      key: const ValueKey('auth_entry_screen'),
      backgroundColor: colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(_heroAssetPath, fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  colorScheme.surface.withValues(alpha: 0),
                  colorScheme.surface,
                ],
                stops: const [0.55, 0.95],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Spacer(),
                  Text(
                    'Training, Ernährung und Regeneration',
                    style: textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bereits über 5.000 + Frauen nutzen ihre LUVI täglich.',
                    style: textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      key: const ValueKey('auth_entry_register_cta'),
                      onPressed: () => context.pushNamed('signup'),
                      child: const Text('Registrieren'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton(
                      key: const ValueKey('auth_entry_login_cta'),
                      onPressed: () => context.pushNamed('login'),
                      child: const Text('Einloggen'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
