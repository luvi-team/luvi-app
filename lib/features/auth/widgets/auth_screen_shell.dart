import 'package:flutter/material.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';

/// Standard wrapper for auth screens that enforces shared padding and
/// keyboard dismissal behaviour.
class AuthScreenShell extends StatelessWidget {
  const AuthScreenShell({
    super.key,
    required this.children,
    this.scrollKey,
    this.includeBottomReserve = true,
    this.controller,
  });

  final List<Widget> children;
  final Key? scrollKey;
  final bool includeBottomReserve;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bottomPad = includeBottomReserve
        ? AuthLayout.ctaBottomInset + safeBottom
        : 0.0;

    return SingleChildScrollView(
      key: scrollKey,
      controller: controller,
      physics: const ClampingScrollPhysics(),
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(
        AuthLayout.horizontalPadding,
        0,
        AuthLayout.horizontalPadding,
        bottomPad,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}
