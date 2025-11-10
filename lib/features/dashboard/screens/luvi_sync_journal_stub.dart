import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

/// Temporary Luvi Sync / Journal destination.
class LuviSyncJournalStubScreen extends StatelessWidget {
  const LuviSyncJournalStubScreen({super.key});

  static const String route = '/luvi-sync';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size20,
      fontWeight: FontWeight.w600,
    );

    final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle())
        .copyWith(
          fontFamily: FontFamilies.figtree,
          fontSize: TypographyTokens.size16,
          height: TypographyTokens.lineHeightRatio24on16,
        );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.dashboardLuviSyncTitle ?? 'Luvi Sync Journal',
          style: titleStyle,
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          l10n?.dashboardLuviSyncPlaceholder ??
              'Luvi Sync Journal content coming soon.',
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
      ),
    );
  }
}
