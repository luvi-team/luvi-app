// Template for new screens
// Replace: {FeatureName}, {ScreenName}, {route_name}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class {ScreenName}Screen extends ConsumerWidget {
  const {ScreenName}Screen({super.key});

  static const routeName = '{route_name}';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: DsColors.splashBg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.l),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: Spacing.xl),
              // Content here
            ],
          ),
        ),
      ),
    );
  }
}
