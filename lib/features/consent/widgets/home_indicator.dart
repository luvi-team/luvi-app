import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/nova_health_tokens.dart';

class HomeIndicator extends StatelessWidget {
  const HomeIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 134,
      height: 5,
      decoration: BoxDecoration(
        color: NovaHealthTokens.grayscaleBlack,
        borderRadius: BorderRadius.circular(100),
      ),
    );
  }
}