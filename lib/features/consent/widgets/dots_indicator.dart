import 'package:flutter/material.dart';
import '../../../core/design_tokens/opacity.dart';
import '../../../core/design_tokens/sizes.dart';
import '../../../core/design_tokens/spacing.dart';

class DotsIndicator extends StatelessWidget {
  const DotsIndicator({
    super.key,
    required this.count,
    required this.activeIndex,
  }) : assert(count > 0);

  final int count;
  final int activeIndex;

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == activeIndex;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.xs),
          child: Container(
            key: ValueKey('dot_$i'),
            width: Sizes.dot,
            height: Sizes.dot,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active
                  ? c.primary
                  : c.outlineVariant.withValues(alpha: OpacityTokens.inactive),
            ),
          ),
        );
      }),
    );
  }
}
