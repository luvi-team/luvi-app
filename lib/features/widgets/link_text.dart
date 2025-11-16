import 'dart:math' as math;

import 'package:flutter/material.dart';

const double _kMinTapSize = 44.0;
const double _kDefaultHorizontalTouchPadding = 8.0; // conservative for inline links

/// Piece of rich text that can optionally behave like a link.
///
/// **Important:** Tappable parts (with [onTap] provided) must have visible text
/// to ensure proper accessibility and usability. Empty text with a tap handler
/// will cause an assertion error in debug mode.
@immutable
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
  }) : assert(
          onTap == null || text.isNotEmpty,
          'Tappable parts must have visible text for accessibility and usability',
        );
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
  ///
  /// Accessibility tradeoff: When overflow is disabled, this widget enforces a
  /// minimum tap-target width equal to [minTapTargetSize] by expanding the
  /// inline hit region horizontally (centered on the text). This may affect
  /// text wrapping in tight layouts. If overflow is enabled, we keep visual
  /// layout unchanged and expand the hit rect outward by
  /// [horizontalTouchPadding], which can overlap adjacent inline areas.
  final bool allowHorizontalOverflowHitRect;

  const LinkText({
    super.key,
    required this.style,
    required this.parts,
    this.minTapTargetSize = _kMinTapSize,
    this.horizontalTouchPadding = _kDefaultHorizontalTouchPadding,
    this.allowHorizontalOverflowHitRect = false,
  })  : assert(minTapTargetSize >= 0, 'minTapTargetSize must be non-negative'),
        assert(
          horizontalTouchPadding >= 0,
          'horizontalTouchPadding must be non-negative',
        );

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
          final styledPartWithColor =
              part.color != null ? partStyle.copyWith(color: part.color) : partStyle;
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

    // When horizontal overflow is not allowed, enforce a minimum tap-target
    // width by adding symmetric padding around the text so the inline box
    // itself grows (centered). This keeps the larger hit region without
    // relying on overflow, at the cost of potentially affecting wrapping.
    double innerHorizontalPadding = 0.0;
    if (!allowHorizontalOverflowHitRect) {
      final textPainter = TextPainter(
        text: TextSpan(text: text, style: resolvedStyle),
        textDirection: Directionality.of(context),
        maxLines: 1,
      )..layout(maxWidth: double.infinity);
      final measuredWidth = textPainter.width;
      final neededHalf =
          math.max(0.0, (minTapTargetSize - measuredWidth) / 2.0);
      // Also respect the configured touch padding as a lower bound inside
      // the inline box when overflow is disabled.
      innerHorizontalPadding =
          math.max(neededHalf, horizontalTouchPadding);
    }

    final content = Stack(
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
          child: Text(text, style: resolvedStyle),
        ),
      ],
    );

    // If overflow is disabled, apply the computed inner padding to expand the
    // inline box width; otherwise keep layout unchanged.
    return innerHorizontalPadding > 0.0
        ? Padding(
            padding: EdgeInsets.symmetric(horizontal: innerHorizontalPadding),
            child: content,
          )
        : content;
  }
}

class _LinkTapRegion extends StatefulWidget {
  final VoidCallback onTap;
  final String semanticsLabel;

  const _LinkTapRegion({required this.onTap, required this.semanticsLabel});

  @override
  State<_LinkTapRegion> createState() => _LinkTapRegionState();
}

class _LinkTapRegionState extends State<_LinkTapRegion> {
  late final FocusNode _focusNode;
  bool _focused = false;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode(debugLabel: 'LinkTapRegion');
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focusColor = theme.colorScheme.primary;
    final hoverColor = theme.colorScheme.primary.withValues(alpha: 0.08);

    return Semantics(
      label: widget.semanticsLabel,
      link: true,
      excludeSemantics: true,
      child: FocusableActionDetector(
        focusNode: _focusNode,
        mouseCursor: SystemMouseCursors.click,
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (intent) {
              widget.onTap();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: _hovered && !_focused ? hoverColor : null,
              border:
                  _focused ? Border.all(color: focusColor, width: 2.0) : null,
              borderRadius: const BorderRadius.all(Radius.circular(4.0)),
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}
