import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/nova_health_tokens.dart';

class PrimaryCtaButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  
  const PrimaryCtaButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: onPressed ?? () {
          debugPrint('$label button pressed');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: NovaHealthTokens.actionPrimary,
          foregroundColor: NovaHealthTokens.grayscaleWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 11,
          ),
        ),
        child: Text(
          label,
          style: NovaHealthTokens.caption1.copyWith(
            color: NovaHealthTokens.grayscaleWhite,
          ),
        ),
      ),
    );
  }
}