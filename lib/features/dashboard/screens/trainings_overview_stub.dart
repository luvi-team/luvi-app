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

    final semanticDescription = l10n.trainingsOverviewStubSemantics;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(l10n.dashboardMoreTrainingsTitle, style: titleStyle),
      ),
      body: Center(
        child: Semantics(
          container: true,
          explicitChildNodes: true,
          label: semanticDescription,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ExcludeSemantics(
                child: Icon(
                  Icons.fitness_center,
                  size: 64,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: Spacing.s),
              Text(
                l10n.trainingsOverviewStubPlaceholder,
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
