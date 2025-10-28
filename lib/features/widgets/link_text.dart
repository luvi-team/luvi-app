import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kMinTapSize = 44.0;
const double _kHorizontalTouchPadding = 18.0;

/// Piece of rich text that can optionally behave like a link.
class LinkTextPart {
  final String text;
  final VoidCallback? onTap;
  final bool bold;
  final Color? color;
  final String? semanticsLabel;

  const LinkTextPart(
    this.text, {
    this.onTap,
    this.bold = false,
    this.color,
    this.semanticsLabel,
  });
}

/// Inline rich text renderer that keeps semantics and analytics wiring consistent.
class LinkText extends StatelessWidget {
  final TextStyle style;
  final List<LinkTextPart> parts;
  final double minTapTargetSize;

  const LinkText({
    super.key,
    required this.style,
    required this.parts,
    this.minTapTargetSize = _kMinTapSize,
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
          if (part.onTap == null) {
            return TextSpan(text: part.text, style: partStyle);
          }
          return WidgetSpan(
            alignment: PlaceholderAlignment.baseline,
            baseline: TextBaseline.alphabetic,
            child: _LinkTextTapTarget(
              text: part.text,
              style: partStyle.copyWith(color: part.color),
              semanticsLabel: part.semanticsLabel,
              onTap: part.onTap!,
              minTapTargetSize: minTapTargetSize,
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

  const _LinkTextTapTarget({
    required this.text,
    required this.style,
    required this.onTap,
    required this.minTapTargetSize,
    this.semanticsLabel,
  });

  @override
  Widget build(BuildContext context) {
    final defaultStyle = DefaultTextStyle.of(context).style;
    final resolvedStyle = defaultStyle.merge(style);
    final fallbackFontSize = defaultStyle.fontSize ?? 14.0;
    final fontSize = resolvedStyle.fontSize ?? fallbackFontSize;
    final baseHeightFactor = resolvedStyle.height ?? defaultStyle.height ?? 1.0;
    final lineHeight = fontSize * baseHeightFactor;
    final verticalPadding = math.max(
      0.0,
      (minTapTargetSize - lineHeight) / 2.0,
    );

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned.fill(
          left: -_kHorizontalTouchPadding,
          right: -_kHorizontalTouchPadding,
          top: -verticalPadding,
          bottom: -verticalPadding,
          child: _LinkTapRegion(
            onTap: onTap,
            semanticsLabel: semanticsLabel ?? text,
          ),
        ),
        Text(text, style: resolvedStyle),
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
      button: true,
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
