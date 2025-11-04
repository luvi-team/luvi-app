import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

class CreateNewHeader extends StatelessWidget {
  const CreateNewHeader({
    super.key,
    required this.headerKey,
    required this.topGap,
  });

  final GlobalKey headerKey;
  final double topGap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );
    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 17,
      height: 25 / 17,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    return Column(
      key: headerKey,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topGap),
        Text(
          'Neues Passwort erstellen 💜',
          key: const ValueKey('create_new_title'),
          style: titleStyle,
        ),
        const SizedBox(height: Spacing.xs),
        Text(
          'Mach es stark.',
          key: const ValueKey('create_new_subtitle'),
          style: subtitleStyle,
        ),
      ],
    );
  }
}
