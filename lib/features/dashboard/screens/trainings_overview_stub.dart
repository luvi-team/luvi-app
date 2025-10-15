import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class TrainingsOverviewStubScreen extends StatelessWidget {
  const TrainingsOverviewStubScreen({super.key});

  static const String route = '/trainings/overview';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle =
        theme.textTheme.titleMedium?.copyWith(
          fontFamily: FontFamilies.figtree,
          fontWeight: FontWeight.w600,
          fontSize: TypographyTokens.size20,
        ) ??
        const TextStyle(
          fontFamily: FontFamilies.figtree,
          fontWeight: FontWeight.w600,
          fontSize: TypographyTokens.size20,
        );
    final bodyStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontFamily: FontFamilies.figtree,
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
        ) ??
        const TextStyle(
          fontFamily: FontFamilies.figtree,
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
        );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(l10n.dashboardMoreTrainingsTitle, style: titleStyle),
      ),
      body: Center(
        child: Semantics(
          label: l10n.dashboardViewMore,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.fitness_center, size: 64, color: Colors.grey),
              const SizedBox(height: Spacing.s),
              Text(
                'Trainingsübersicht folgt bald',
                textAlign: TextAlign.center,
                style: bodyStyle,
              ),
              const SizedBox(height: Spacing.m),
              ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(
                  MaterialLocalizations.of(context).backButtonTooltip,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
