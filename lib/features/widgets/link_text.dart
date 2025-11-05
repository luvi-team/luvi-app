import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kMinTapSize = 44.0;
const double _kDefaultHorizontalTouchPadding = 8.0; // conservative for inline links

/// Piece of rich text that can optionally behave like a link.
///
/// **Important:** Tappable parts (with [onTap] provided) must have visible text
/// to ensure proper accessibility and usability. Empty text with a tap handler
/// will cause an assertion error in debug mode.
class LinkTextPart {
  final String text;
  final VoidCallback? onTap;
  final bool bold;
  final Color? color;
  final String? semanticsLabel;

  LinkTextPart(
    this.text, {
    this.onTap,
    this.bold = false,
    this.color,
    this.semanticsLabel,
  }) : assert(onTap == null || text.isNotEmpty,
            'Tappable parts must have visible text for accessibility and usability');
}

/// Inline rich text renderer that keeps semantics and analytics wiring consistent.
class LinkText extends StatelessWidget {
  final TextStyle style;
  final List<LinkTextPart> parts;
  final double minTapTargetSize;
  /// Horizontal padding (per side) to expand the tap target of inline links.
  /// Keep small to avoid overlapping adjacent link targets in dense text.
  final double horizontalTouchPadding;
  /// When true, the horizontal hit rect may overflow beyond the text bounds
  /// by [horizontalTouchPadding]. When false, the hit rect is clipped to the
  /// inline box width (no horizontal overflow), reducing overlap risk.
  final bool allowHorizontalOverflowHitRect;

  const LinkText({
    super.key,
    required this.style,
    required this.parts,
    this.minTapTargetSize = _kMinTapSize,
    this.horizontalTouchPadding = _kDefaultHorizontalTouchPadding,
    this.allowHorizontalOverflowHitRect = false,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final resolvedBaseStyle = defaultStyle.merge(style);

    return Text.rich(
      TextSpan(
        style: resolvedBaseStyle,
        children: parts.map((part) {
          final partStyle = part.bold
              ? resolvedBaseStyle.copyWith(fontWeight: FontWeight.w700)
              : resolvedBaseStyle;
          final styledPartWithColor = part.color != null 
              ? partStyle.copyWith(color: part.color)
              : partStyle;
          if (part.onTap == null) {
            return TextSpan(text: part.text, style: styledPartWithColor);
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _LinkTextTapTarget(
              text: part.text,
              style: styledPartWithColor,
              semanticsLabel: part.semanticsLabel,
              onTap: part.onTap!,
              minTapTargetSize: minTapTargetSize,
              horizontalTouchPadding: horizontalTouchPadding,
              allowHorizontalOverflowHitRect: allowHorizontalOverflowHitRect,
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _LinkTextTapTarget extends StatelessWidget {
  final String text;
  final TextStyle style;
  final String? semanticsLabel;
  final VoidCallback onTap;
  final double minTapTargetSize;
  final double horizontalTouchPadding;
  final bool allowHorizontalOverflowHitRect;

  const _LinkTextTapTarget({
    required this.text,
    required this.style,
    required this.onTap,
    required this.minTapTargetSize,
    required this.horizontalTouchPadding,
    required this.allowHorizontalOverflowHitRect,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final fontSize = style.fontSize ?? DefaultTextStyle.of(context).style.fontSize ?? 14.0;
    final baseHeightFactor = style.height ?? DefaultTextStyle.of(context).style.height ?? 1.0;
    final lineHeight = fontSize * baseHeightFactor;
    final verticalPadding = math.max(
      0.0,
      (minTapTargetSize - lineHeight) / 2.0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: allowHorizontalOverflowHitRect ? -horizontalTouchPadding : 0.0,
          right: allowHorizontalOverflowHitRect ? -horizontalTouchPadding : 0.0,
          top: -verticalPadding,
          bottom: -verticalPadding,
          child: _LinkTapRegion(
            onTap: onTap,
            semanticsLabel: semanticsLabel ?? text,
          ),
        ),
        ExcludeSemantics(
          child: Text(text, style: style),
        ),
      ],
    );
  }
}

class _LinkTapRegion extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticsLabel;

  const _LinkTapRegion({required this.onTap, required this.semanticsLabel});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticsLabel,
      link: true,
      excludeSemantics: true,
      child: FocusableActionDetector(
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: onTap,
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}
