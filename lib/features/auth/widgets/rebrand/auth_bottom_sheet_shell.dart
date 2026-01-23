import 'package:flutter/material.dart';
import 'package:luvi_app/core/design_tokens/colors.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'auth_rainbow_background.dart';
import 'auth_rebrand_metrics.dart';

/// Bottom sheet shell for Auth Rebrand v3 overlays (Register/Login).
///
/// Features:
/// - Fixed height with rounded top corners (radius 40)
/// - Top white border (2px)
/// - Drag indicator
/// - Rainbow background painter
/// - Centered content area
class AuthBottomSheetShell extends StatelessWidget {
  const AuthBottomSheetShell({
    super.key,
    required this.child,
  });

  /// The content to display in the sheet
  final Widget child;

  /// Shows the auth bottom sheet modal.
  ///
  /// Call this static method to display the sheet:
  /// ```dart
  /// AuthBottomSheetShell.show(
  ///   context: context,
  ///   builder: (context) => YourContent(),
  /// );
  /// ```
  static Future<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: DsColors.transparent,
      barrierColor: DsColors.authRebrandBarrier,
      // shape is omitted: backgroundColor is transparent, so visual rounding
      // is handled by the Container decoration inside AuthBottomSheetShell.
      builder: (context) => AuthBottomSheetShell(
        child: builder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final topPadding = MediaQuery.paddingOf(context).top;
    // Figma baseline: sheetTopY (253) = statusBarHeight (47) + contentOffset (206)
    // Adjust for actual device's safe area inset to handle notches/Dynamic Island
    const contentOffsetBelowStatusBar =
        AuthRebrandMetrics.sheetTopY - AuthRebrandMetrics.statusBarHeight;
    final sheetHeight = screenHeight - topPadding - contentOffsetBelowStatusBar;

    return Container(
      height: sheetHeight,
      decoration: const BoxDecoration(
        color: DsColors.authRebrandBackground,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AuthRebrandMetrics.sheetRadius),
        ),
        border: Border(
          top: BorderSide(
            color: DsColors.grayscaleWhite,
            width: 2,
          ),
        ),
      ),
      child: Stack(
        children: [
          // Rainbow background
          ClipRRect(
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AuthRebrandMetrics.sheetRadius),
            ),
            child: SizedBox(
              height: sheetHeight,
              width: double.infinity,
              child: const AuthRainbowBackground(),
            ),
          ),

          // Content with drag indicator
          Column(
            children: [
              // Drag indicator (SSOT: 134×5, top=17, color=#030401, radius=100)
              const SizedBox(height: AuthRebrandMetrics.sheetDragIndicatorTop),
              Semantics(
                label: AppLocalizations.of(context)?.authDragHandleSemantic ??
                    'Drag handle', // A11y fallback: English default when l10n unavailable
                excludeSemantics: true,
                child: Container(
                  width: AuthRebrandMetrics.sheetDragIndicatorWidth,
                  height: AuthRebrandMetrics.sheetDragIndicatorHeight,
                  decoration: BoxDecoration(
                    color: DsColors.grayscaleBlack,
                    borderRadius: BorderRadius.circular(
                      AuthRebrandMetrics.sheetDragIndicatorRadius,
                    ),
                  ),
                ),
              ),

              // Content area
              Expanded(
                child: SafeArea(
                  top: false,
                  bottom: true,
                  child: child,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
