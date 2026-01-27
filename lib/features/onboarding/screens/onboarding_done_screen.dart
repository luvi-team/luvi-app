import 'package:flutter/material.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Final placeholder screen shown after onboarding flow completes.
///
/// This is a minimal screen that displays a completion message.
/// In production, users are typically redirected before seeing this screen.
class OnboardingDoneScreen extends StatelessWidget {
  const OnboardingDoneScreen({super.key});

  /// Route path for navigation
  static const routeName = '/onboarding/done';

  /// GoRoute name for pushNamed navigation
  static const navName = 'onboarding_done';

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(AppLocalizations.of(context)!.onboardingComplete),
    );
  }
}
