import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class WorkoutDetailStubScreen extends StatelessWidget {
  const WorkoutDetailStubScreen({super.key, required this.workoutId});

  final String workoutId;

  static const String route = '/workout/:id';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size20,
      fontWeight: FontWeight.w600,
    ) ?? const TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size20,
      fontWeight: FontWeight.w600,
    );

    final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: TypographyTokens.size16,
      height: TypographyTokens.lineHeightRatio24on16,
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        title: Text(
          l10n.workoutTitle,
          style: titleStyle,
        ),
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Text(
          'Workout Detail (Stub)\nID: $workoutId',
          textAlign: TextAlign.center,
          style: bodyStyle,
        ),
      ),
    );
  }
}
