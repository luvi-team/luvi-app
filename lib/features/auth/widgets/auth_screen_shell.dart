import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

/// Standard wrapper for auth screens that enforces shared padding and
/// keyboard dismissal behaviour.
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final padding = EdgeInsets.fromLTRB(
      AuthLayout.horizontalPadding,
      0,
      AuthLayout.horizontalPadding,
      AuthLayout.ctaBottomInset + safeBottom,
    );

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    );
  }
}
