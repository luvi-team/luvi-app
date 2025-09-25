import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';

class GlobalErrorBanner extends StatelessWidget {
  const GlobalErrorBanner({
    super.key,
    required this.message,
    this.onTap,
  });

  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final banner = Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(Spacing.s),
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(Spacing.s),
        ),
        child: Text(
          message,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontSize: 15,
            height: 1.4,
            color: colorScheme.error,
          ),
        ),
      ),
    );

    if (onTap == null) {
      return banner;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: banner,
    );
  }
}
