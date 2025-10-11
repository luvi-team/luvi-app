import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/typography.dart';

class WorkoutDetailStubScreen extends StatelessWidget {
  const WorkoutDetailStubScreen({super.key, required this.workoutId});

  final String workoutId;

  static const String route = '/workout/:id';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    // Before: no fallback here
    final titleStyle = theme.textTheme.titleMedium?.copyWith(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size20,
      fontWeight: FontWeight.w600,
    ) 
    // Add a single, centralized fallback
    ?? const TextStyle(
      fontFamily: FontFamilies.figtree,
      fontSize: TypographyTokens.size20,
      fontWeight: FontWeight.w600,
    );

    // …later in the AppBar…

         title: Text(
           'Workout',
           style: titleStyle,
         ),
    final bodyStyle = (theme.textTheme.bodyMedium ?? const TextStyle()).copyWith(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: TypographyTokens.size16,
      height: TypographyTokens.lineHeightRatio24on16,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Workout',
          style: titleStyle ??
              const TextStyle(
                fontFamily: FontFamilies.figtree,
                fontSize: TypographyTokens.size20,
                fontWeight: FontWeight.w600,
              ),
        ),
        elevation: 0,
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
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
