import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';

import '../design_tokens/colors.dart';
import '../design_tokens/typography.dart';
import '../design_tokens/spacing.dart';
import '../design_tokens/sizes.dart';
import '../design_tokens/dashboard_typography_tokens.dart';
import '../design_tokens/divider_tokens.dart';

List<double> _lerpDoubleList(List<double> a, List<double> b, double t) {
  final minLength = a.length < b.length ? a.length : b.length;
  final result = <double>[];
  for (var i = 0; i < minLength; i++) {
    result.add(lerpDouble(a[i], b[i], t) ?? a[i]);
  }
  if (a.length > minLength) {
    result.addAll(a.sublist(minLength));
  } else if (b.length > minLength) {
    result.addAll(b.sublist(minLength));
  }
  return result;
}

List<Color> _lerpColorList(List<Color> a, List<Color> b, double t) {
  final minLength = a.length < b.length ? a.length : b.length;
  final result = <Color>[];
  for (var i = 0; i < minLength; i++) {
    result.add(Color.lerp(a[i], b[i], t) ?? a[i]);
  }
  if (a.length > minLength) {
    result.addAll(a.sublist(minLength));
  } else if (b.length > minLength) {
    result.addAll(b.sublist(minLength));
  }
  return result;
}

/// Minimal theme scaffold for the LUVI app.
/// This is a placeholder for future design system implementation.
class AppTheme {
  // Colors from Figma CSS
  static const Color _primary = Color(
    0xFFD9B18E,
  ); // Primary color/100 (Button bg)
  static const Color _accentSubtle = Color(
    0xFFD9B6A3,
  ); // Accent-Subtle (nur "Superkraft.")
  static const Color _onPrimary = Color(
    0xFF030401,
  ); // Grayscale/Black (CTA text on Gold)
  static const Color _onSurface = Color(0xFF030401); // Grayscale/Black
  static const Color _grayscale400 = Color(
    0xFFB0B0B0,
  ); // Grayscale/400 (Dots inactive base)

  static const TextTheme _textThemeConst = TextTheme(
    // H1
    headlineMedium: TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontWeight: FontWeight.w400,
      fontSize: TypographyTokens.size32,
      height: TypographyTokens.lineHeightRatio40on32,
      letterSpacing: 0,
    ),
    // Body Regular
    bodyMedium: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: TypographyTokens.size20,
      height: TypographyTokens.lineHeightRatio24on20,
      letterSpacing: 0,
    ),
    // Button Label (bold)
    labelLarge: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w700,
      fontSize: TypographyTokens.size20,
      height: TypographyTokens.lineHeightRatio24on20,
      letterSpacing: 0,
    ),
    // Skip / small
    bodySmall: TextStyle(
      fontFamily: FontFamilies.inter,
      fontWeight: FontWeight.w500,
      fontSize: TypographyTokens.size14,
      height: TypographyTokens.lineHeightRatio24on14,
      letterSpacing: 0,
    ),
  );

  /// Builds the app theme configuration.
  static ThemeData buildAppTheme() {
    return ThemeData(
      useMaterial3: true,
      // Keep global default as Playfair to avoid unexpected fallbacks for styles
      fontFamily: FontFamilies.playfairDisplay,
      colorScheme: _buildColorScheme(),
      scaffoldBackgroundColor: Colors.white,
      textTheme: _buildTextTheme(),
      // Centralize common UI measurements to remove magic numbers in widgets
      iconTheme: const IconThemeData(size: TypographyTokens.size20),
      dividerTheme: const DividerThemeData(thickness: 1.0),
      // Button global stylen wie Figma
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      textButtonTheme: _buildTextButtonTheme(),
      extensions: const <ThemeExtension<dynamic>>[
        DsTokens.light,
        TextColorTokens.light,
        SurfaceColorTokens.light,
        DashboardLayoutTokens.light,
        CyclePhaseTokens.light,
        CalendarRadiusTokens.light,
        ShadowTokens.light,
        GlassTokens.light,
        WorkoutCardTypographyTokens.light,
        WorkoutCardOverlayTokens.light,
        RecommendationCardOverlayTokens.light,
        DashboardTypographyTokens.light,
        DividerTokens.light,
      ],
    );
  }

  static ColorScheme _buildColorScheme() {
    return ColorScheme.fromSeed(
      seedColor: _primary,
      primary: _primary,
      secondary: _accentSubtle, // für "Superkraft."
      surface: Colors.white,
      onPrimary: _onPrimary,
      onSurface: _onSurface,
      outlineVariant: _grayscale400, // für Dots inactive (mit Opacity)
    );
  }

  static TextTheme _buildTextTheme() => _textThemeConst;

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _primary,
        foregroundColor: _onPrimary,
        minimumSize: Size.fromHeight(Sizes.buttonHeight),
        padding: const EdgeInsets.symmetric(
          horizontal: Spacing.s,
          vertical: Spacing.s,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Sizes.radiusM),
        ),
        textStyle: const TextStyle(
          fontFamily: FontFamilies.figtree,
          fontWeight: FontWeight.w700,
          fontSize: TypographyTokens.size20,
          height: TypographyTokens.lineHeightRatio24on20,
        ),
        elevation: 0,
      ),
    );
  }

  static TextButtonThemeData _buildTextButtonTheme() {
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: _onSurface,
        textStyle: const TextStyle(
          fontFamily: FontFamilies.inter,
          fontWeight: FontWeight.w500,
          fontSize: TypographyTokens.size14,
          height: TypographyTokens.lineHeightRatio24on14,
        ),
      ),
    );
  }
}

/// Design System tokens not covered by Material ColorScheme.
/// Extendable for dark mode or brand variants without touching widgets.
@immutable
class DsTokens extends ThemeExtension<DsTokens> {
  const DsTokens({
    required this.cardSurface,
    required this.cardBorderSelected,
    required this.inputBorder,
    required this.grayscale500,
    required this.successColor,
    required this.inputBorderLight,
    required this.authEntrySubhead,
    required this.accentPurple,
    required this.color,
  });

  final Color cardSurface; // Grayscale/100 (#F7F7F8)
  final Color cardBorderSelected; // Secondary/100 (#1C1411)
  final Color inputBorder; // Neutral border for inputs
  final Color grayscale500; // Placeholder / secondary text
  final Color successColor; // Message/Green (#04B155)
  final Color inputBorderLight; // Subtle borders (#F7F7F8)
  final TextStyle
  authEntrySubhead; // Auth Entry subhead typography (shape-only)
  final Color accentPurple; // Accent/300 (#CCB2F4) - dock wave, sync button
  final DsColorTokens color; // Nested DS color tokens

  static const DsTokens light = DsTokens(
    cardSurface: Color(0xFFF7F7F8),
    cardBorderSelected: Color(0xFF1C1411),
    inputBorder: Color(0xFFDCDCDC),
    grayscale500: Color(0xFF696969),
    successColor: Color(0xFF04B155),
    inputBorderLight: Color(0xFFF7F7F8),
    authEntrySubhead: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w500,
      fontSize: 14,
      height: 20 / 14,
      letterSpacing: 0,
    ),
    accentPurple: Color(0xFFCCB2F4),
    color: DsColorTokens.light,
  );

  @override
  DsTokens copyWith({
    Color? cardSurface,
    Color? cardBorderSelected,
    Color? inputBorder,
    Color? grayscale500,
    Color? successColor,
    Color? inputBorderLight,
    TextStyle? authEntrySubhead,
    Color? accentPurple,
    DsColorTokens? color,
  }) => DsTokens(
    cardSurface: cardSurface ?? this.cardSurface,
    cardBorderSelected: cardBorderSelected ?? this.cardBorderSelected,
    inputBorder: inputBorder ?? this.inputBorder,
    grayscale500: grayscale500 ?? this.grayscale500,
    successColor: successColor ?? this.successColor,
    inputBorderLight: inputBorderLight ?? this.inputBorderLight,
    authEntrySubhead: authEntrySubhead ?? this.authEntrySubhead,
    accentPurple: accentPurple ?? this.accentPurple,
    color: color ?? this.color,
  );

  @override
  DsTokens lerp(ThemeExtension<DsTokens>? other, double t) {
    if (other is! DsTokens) return this;
    return DsTokens(
      cardSurface: Color.lerp(cardSurface, other.cardSurface, t) ?? cardSurface,
      cardBorderSelected:
          Color.lerp(cardBorderSelected, other.cardBorderSelected, t) ??
          cardBorderSelected,
      inputBorder: Color.lerp(inputBorder, other.inputBorder, t) ?? inputBorder,
      grayscale500:
          Color.lerp(grayscale500, other.grayscale500, t) ?? grayscale500,
      successColor:
          Color.lerp(successColor, other.successColor, t) ?? successColor,
      inputBorderLight:
          Color.lerp(inputBorderLight, other.inputBorderLight, t) ??
          inputBorderLight,
      authEntrySubhead:
          TextStyle.lerp(authEntrySubhead, other.authEntrySubhead, t) ??
          authEntrySubhead,
      accentPurple:
          Color.lerp(accentPurple, other.accentPurple, t) ?? accentPurple,
      color: color.lerp(other.color, t),
    );
  }
}

@immutable
class DsColorTokens {
  const DsColorTokens({required this.icon});

  final DsIconColorTokens icon;

  static const DsColorTokens light = DsColorTokens(
    icon: DsIconColorTokens(
      badge: DsIconBadgeColorTokens(goldCircle: Color(0xFFD9B18E)),
    ),
  );

  DsColorTokens copyWith({DsIconColorTokens? icon}) =>
      DsColorTokens(icon: icon ?? this.icon);

  DsColorTokens lerp(DsColorTokens other, double t) =>
      DsColorTokens(icon: icon.lerp(other.icon, t));
}

@immutable
class DsIconColorTokens {
  const DsIconColorTokens({required this.badge});

  final DsIconBadgeColorTokens badge;

  DsIconColorTokens copyWith({DsIconBadgeColorTokens? badge}) =>
      DsIconColorTokens(badge: badge ?? this.badge);

  DsIconColorTokens lerp(DsIconColorTokens other, double t) =>
      DsIconColorTokens(badge: badge.lerp(other.badge, t));
}

@immutable
class DsIconBadgeColorTokens {
  const DsIconBadgeColorTokens({required this.goldCircle});

  final Color goldCircle;

  DsIconBadgeColorTokens copyWith({Color? goldCircle}) =>
      DsIconBadgeColorTokens(goldCircle: goldCircle ?? this.goldCircle);

  DsIconBadgeColorTokens lerp(DsIconBadgeColorTokens other, double t) =>
      DsIconBadgeColorTokens(
        goldCircle: Color.lerp(goldCircle, other.goldCircle, t) ?? goldCircle,
      );
}

@immutable
class TextColorTokens extends ThemeExtension<TextColorTokens> {
  const TextColorTokens({
    required this.primary,
    required this.secondary,
    required this.muted,
  });

  final Color primary;
  final Color secondary;
  final Color muted;

  static const TextColorTokens light = TextColorTokens(
    primary: DsColors.textPrimary,
    secondary: DsColors.textSecondary,
    muted: DsColors.textMuted,
  );

  @override
  TextColorTokens copyWith({Color? primary, Color? secondary, Color? muted}) =>
      TextColorTokens(
        primary: primary ?? this.primary,
        secondary: secondary ?? this.secondary,
        muted: muted ?? this.muted,
      );

  @override
  TextColorTokens lerp(ThemeExtension<TextColorTokens>? other, double t) {
    if (other is! TextColorTokens) return this;
    return TextColorTokens(
      primary: Color.lerp(primary, other.primary, t) ?? primary,
      secondary: Color.lerp(secondary, other.secondary, t) ?? secondary,
      muted: Color.lerp(muted, other.muted, t) ?? muted,
    );
  }
}

@immutable
class SurfaceColorTokens extends ThemeExtension<SurfaceColorTokens> {
  const SurfaceColorTokens({
    required this.infoBackground,
    required this.cardBackgroundNeutral,
    required this.white,
    required this.waveOverlayPink,
    required this.waveOverlayBeige,
  });

  final Color infoBackground;
  final Color cardBackgroundNeutral;
  final Color white;
  final Color waveOverlayPink;
  // Beige tint for recommendations section wave (Figma spec #D9B18E @ 15%).
  final Color waveOverlayBeige;

  static const SurfaceColorTokens light = SurfaceColorTokens(
    infoBackground: DsColors.infoBackground,
    cardBackgroundNeutral: DsColors.cardBackgroundNeutral,
    white: DsColors.white,
    waveOverlayPink: DsColors
        .waveOverlayPink, // TODO(theme-dark): adjust for dark theme variant.
    waveOverlayBeige: Color(
      0x26D9B18E,
    ), // Beige wave tint at 15% opacity (Figma spec #D9B18E @ 15%)
  );

  @override
  SurfaceColorTokens copyWith({
    Color? infoBackground,
    Color? cardBackgroundNeutral,
    Color? white,
    Color? waveOverlayPink,
    Color? waveOverlayBeige,
  }) => SurfaceColorTokens(
    infoBackground: infoBackground ?? this.infoBackground,
    cardBackgroundNeutral: cardBackgroundNeutral ?? this.cardBackgroundNeutral,
    white: white ?? this.white,
    waveOverlayPink: waveOverlayPink ?? this.waveOverlayPink,
    waveOverlayBeige: waveOverlayBeige ?? this.waveOverlayBeige,
  );

  @override
  SurfaceColorTokens lerp(ThemeExtension<SurfaceColorTokens>? other, double t) {
    if (other is! SurfaceColorTokens) return this;
    return SurfaceColorTokens(
      infoBackground:
          Color.lerp(infoBackground, other.infoBackground, t) ?? infoBackground,
      cardBackgroundNeutral:
          Color.lerp(cardBackgroundNeutral, other.cardBackgroundNeutral, t) ??
          cardBackgroundNeutral,
      white: Color.lerp(white, other.white, t) ?? white,
      waveOverlayPink:
          Color.lerp(waveOverlayPink, other.waveOverlayPink, t) ??
          waveOverlayPink,
      waveOverlayBeige:
          Color.lerp(waveOverlayBeige, other.waveOverlayBeige, t) ??
          waveOverlayBeige,
    );
  }
}

@immutable
class DashboardLayoutTokens extends ThemeExtension<DashboardLayoutTokens> {
  const DashboardLayoutTokens({
    required this.waveHeightPx,
    required this.heroHorizontalMarginPx,
    required this.calendarToWaveGapPx,
    required this.heroToSectionGapPx,
    required this.waveAmplitudePink,
  });

  final double waveHeightPx;
  final double heroHorizontalMarginPx;
  final double calendarToWaveGapPx;
  final double heroToSectionGapPx;
  // Pink wave amplitude above hero card (Figma audit Phase 1)
  final double waveAmplitudePink;

  static const DashboardLayoutTokens light = DashboardLayoutTokens(
    // Audit node 68672:7392 → hero frame y=216, h=249. Wave overlay height derived as 249 - 21 gap = 228 px.
    waveHeightPx: 228,
    // Audit spacing observedValues 21px hero workout frame margins (docs/audits/DASHBOARD_figma_audit_v2.json).
    heroHorizontalMarginPx: 21,
    // Calendar (node 68672:7364) bottom at y=195 vs hero top y=216 → 21 px gap filled by wave overlay.
    calendarToWaveGapPx: 21,
    // Audit observed main vertical gap between hero bottom and first section title.
    heroToSectionGapPx: 42,
    // Pink wave curved lip height (Figma node 68721:7519, reduced from 24px to 22px per audit)
    waveAmplitudePink: 22.0,
  );

  @override
  DashboardLayoutTokens copyWith({
    double? waveHeightPx,
    double? heroHorizontalMarginPx,
    double? calendarToWaveGapPx,
    double? heroToSectionGapPx,
    double? waveAmplitudePink,
  }) => DashboardLayoutTokens(
    waveHeightPx: waveHeightPx ?? this.waveHeightPx,
    heroHorizontalMarginPx:
        heroHorizontalMarginPx ?? this.heroHorizontalMarginPx,
    calendarToWaveGapPx: calendarToWaveGapPx ?? this.calendarToWaveGapPx,
    heroToSectionGapPx: heroToSectionGapPx ?? this.heroToSectionGapPx,
    waveAmplitudePink: waveAmplitudePink ?? this.waveAmplitudePink,
  );

  @override
  DashboardLayoutTokens lerp(
    ThemeExtension<DashboardLayoutTokens>? other,
    double t,
  ) {
    if (other is! DashboardLayoutTokens) return this;
    return DashboardLayoutTokens(
      waveHeightPx:
          lerpDouble(waveHeightPx, other.waveHeightPx, t) ?? waveHeightPx,
      heroHorizontalMarginPx:
          lerpDouble(heroHorizontalMarginPx, other.heroHorizontalMarginPx, t) ??
          heroHorizontalMarginPx,
      calendarToWaveGapPx:
          lerpDouble(calendarToWaveGapPx, other.calendarToWaveGapPx, t) ??
          calendarToWaveGapPx,
      heroToSectionGapPx:
          lerpDouble(heroToSectionGapPx, other.heroToSectionGapPx, t) ??
          heroToSectionGapPx,
      waveAmplitudePink:
          lerpDouble(waveAmplitudePink, other.waveAmplitudePink, t) ??
          waveAmplitudePink,
    );
  }
}

@immutable
class CyclePhaseTokens extends ThemeExtension<CyclePhaseTokens> {
  const CyclePhaseTokens({
    required this.follicularDark,
    required this.follicularLight,
    required this.ovulation,
    required this.luteal,
    required this.menstruation,
  });

  final Color follicularDark;
  final Color follicularLight;
  final Color ovulation;
  final Color luteal;
  final Color menstruation;

  static const CyclePhaseTokens light = CyclePhaseTokens(
    follicularDark: DsColors.phaseFollicularDark,
    follicularLight: DsColors.phaseFollicularLight,
    ovulation: DsColors.phaseOvulation,
    luteal: DsColors.phaseLuteal,
    menstruation: DsColors.phaseMenstruation,
  );

  @override
  CyclePhaseTokens copyWith({
    Color? follicularDark,
    Color? follicularLight,
    Color? ovulation,
    Color? luteal,
    Color? menstruation,
  }) => CyclePhaseTokens(
    follicularDark: follicularDark ?? this.follicularDark,
    follicularLight: follicularLight ?? this.follicularLight,
    ovulation: ovulation ?? this.ovulation,
    luteal: luteal ?? this.luteal,
    menstruation: menstruation ?? this.menstruation,
  );

  @override
  CyclePhaseTokens lerp(ThemeExtension<CyclePhaseTokens>? other, double t) {
    if (other is! CyclePhaseTokens) return this;
    return CyclePhaseTokens(
      follicularDark:
          Color.lerp(follicularDark, other.follicularDark, t) ?? follicularDark,
      follicularLight:
          Color.lerp(follicularLight, other.follicularLight, t) ??
          follicularLight,
      ovulation: Color.lerp(ovulation, other.ovulation, t) ?? ovulation,
      luteal: Color.lerp(luteal, other.luteal, t) ?? luteal,
      menstruation:
          Color.lerp(menstruation, other.menstruation, t) ?? menstruation,
    );
  }
}

@immutable
class CalendarRadiusTokens extends ThemeExtension<CalendarRadiusTokens> {
  const CalendarRadiusTokens({
    required this.calendarChip,
    required this.calendarSegmentEdge,
    required this.calendarSegmentInner,
    required this.calendarGap,
    required this.cardLarge,
    required this.cardStat,
    required this.cardWorkout,
  });

  final double calendarChip;
  final double calendarSegmentEdge;
  final double calendarSegmentInner;
  final double calendarGap;
  final double cardLarge;
  final double cardStat;
  final double cardWorkout;

  static const CalendarRadiusTokens light = CalendarRadiusTokens(
    calendarChip: 40.0,
    calendarSegmentEdge: 0.0,
    calendarSegmentInner: 40.0,
    calendarGap: 4.0,
    cardLarge: 24.0,
    cardStat: 24.0,
    cardWorkout: 20.0,
  );

  @override
  CalendarRadiusTokens copyWith({
    double? calendarChip,
    double? calendarSegmentEdge,
    double? calendarSegmentInner,
    double? calendarGap,
    double? cardLarge,
    double? cardStat,
    double? cardWorkout,
  }) => CalendarRadiusTokens(
    calendarChip: calendarChip ?? this.calendarChip,
    calendarSegmentEdge: calendarSegmentEdge ?? this.calendarSegmentEdge,
    calendarSegmentInner: calendarSegmentInner ?? this.calendarSegmentInner,
    calendarGap: calendarGap ?? this.calendarGap,
    cardLarge: cardLarge ?? this.cardLarge,
    cardStat: cardStat ?? this.cardStat,
    cardWorkout: cardWorkout ?? this.cardWorkout,
  );

  @override
  CalendarRadiusTokens lerp(
    ThemeExtension<CalendarRadiusTokens>? other,
    double t,
  ) {
    if (other is! CalendarRadiusTokens) return this;
    return CalendarRadiusTokens(
      calendarChip:
          lerpDouble(calendarChip, other.calendarChip, t) ?? calendarChip,
      calendarSegmentEdge:
          lerpDouble(calendarSegmentEdge, other.calendarSegmentEdge, t) ??
          calendarSegmentEdge,
      calendarSegmentInner:
          lerpDouble(calendarSegmentInner, other.calendarSegmentInner, t) ??
          calendarSegmentInner,
      calendarGap: lerpDouble(calendarGap, other.calendarGap, t) ?? calendarGap,
      cardLarge: lerpDouble(cardLarge, other.cardLarge, t) ?? cardLarge,
      cardStat: lerpDouble(cardStat, other.cardStat, t) ?? cardStat,
      cardWorkout: lerpDouble(cardWorkout, other.cardWorkout, t) ?? cardWorkout,
    );
  }
}

@immutable
class ShadowTokens extends ThemeExtension<ShadowTokens> {
  const ShadowTokens({
    required this.heroDrop,
    required this.tileDrop,
    required this.heroCardDrop,
    required this.heroCalloutTextShadow,
  });

  final BoxShadow heroDrop;
  final BoxShadow tileDrop;

  /// Desktop/web fallback that mirrors Material elevation 4 used on mobile.
  final BoxShadow heroCardDrop;
  // Text-shadow for hero card callout text (Figma audit Phase 1)
  final Shadow heroCalloutTextShadow;

  static const ShadowTokens light = ShadowTokens(
    heroDrop: BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color(
        0x20000000,
      ), // 12.5% alpha (reduced from 25% for subtler shadows)
    ),
    heroCardDrop: BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color(0x40000000), // 25% alpha to match hero card spec
    ),
    tileDrop: BoxShadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      spreadRadius: 0,
      color: Color(
        0x20000000,
      ), // 12.5% alpha (reduced from 25% for subtler shadows)
    ),
    heroCalloutTextShadow: Shadow(
      offset: Offset(0, 4),
      blurRadius: 4,
      color: Color(
        0x20000000,
      ), // 12.5% alpha (reduced from 25% for subtler shadows)
    ),
  );

  @override
  ShadowTokens copyWith({
    BoxShadow? heroDrop,
    BoxShadow? tileDrop,
    BoxShadow? heroCardDrop,
    Shadow? heroCalloutTextShadow,
  }) => ShadowTokens(
    heroDrop: heroDrop ?? this.heroDrop,
    tileDrop: tileDrop ?? this.tileDrop,
    heroCardDrop: heroCardDrop ?? this.heroCardDrop,
    heroCalloutTextShadow: heroCalloutTextShadow ?? this.heroCalloutTextShadow,
  );

  @override
  ShadowTokens lerp(ThemeExtension<ShadowTokens>? other, double t) {
    if (other is! ShadowTokens) return this;
    return ShadowTokens(
      heroDrop: BoxShadow.lerp(heroDrop, other.heroDrop, t) ?? heroDrop,
      tileDrop: BoxShadow.lerp(tileDrop, other.tileDrop, t) ?? tileDrop,
      heroCardDrop:
          BoxShadow.lerp(heroCardDrop, other.heroCardDrop, t) ?? heroCardDrop,
      heroCalloutTextShadow:
          Shadow.lerp(heroCalloutTextShadow, other.heroCalloutTextShadow, t) ??
          heroCalloutTextShadow,
    );
  }
}

@immutable
class GlassTokens extends ThemeExtension<GlassTokens> {
  const GlassTokens({
    required this.background,
    required this.border,
    required this.blur,
  });

  final Color background;
  final BorderSide border;
  final double blur;

  static const GlassTokens light = GlassTokens(
    background: Color(0x8CFFFFFF),
    border: BorderSide(color: Color(0x14000000), width: 1),
    blur: 16,
  );

  @override
  GlassTokens copyWith({Color? background, BorderSide? border, double? blur}) =>
      GlassTokens(
        background: background ?? this.background,
        border: border ?? this.border,
        blur: blur ?? this.blur,
      );

  @override
  GlassTokens lerp(ThemeExtension<GlassTokens>? other, double t) {
    if (other is! GlassTokens) return this;
    return GlassTokens(
      background: Color.lerp(background, other.background, t) ?? background,
      border: BorderSide.lerp(border, other.border, t),
      blur: lerpDouble(blur, other.blur, t) ?? blur,
    );
  }
}

@immutable
class WorkoutCardTypographyTokens
    extends ThemeExtension<WorkoutCardTypographyTokens> {
  const WorkoutCardTypographyTokens({
    required this.titleStyle,
    required this.subtitleStyle,
    required this.durationStyle,
    required this.sectionSubtitleStyle,
  });

  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final TextStyle durationStyle;
  final TextStyle sectionSubtitleStyle;

  static const WorkoutCardTypographyTokens light = WorkoutCardTypographyTokens(
    // Requires PlayfairDisplay-Bold, Figtree-Regular, and Figtree-Italic fonts in pubspec.
    titleStyle: TextStyle(
      fontFamily: FontFamilies.playfairDisplay,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 32 / 24,
    ),
    subtitleStyle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
    ),
    durationStyle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 12,
      height: 24 / 12,
      color: Color(0x99FFFFFF),
    ),
    sectionSubtitleStyle: TextStyle(
      fontFamily: FontFamilies.figtree,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      fontStyle: FontStyle.italic,
      color: Color(0xFF696969),
    ),
  );

  @override
  WorkoutCardTypographyTokens copyWith({
    TextStyle? titleStyle,
    TextStyle? subtitleStyle,
    TextStyle? durationStyle,
    TextStyle? sectionSubtitleStyle,
  }) => WorkoutCardTypographyTokens(
    titleStyle: titleStyle ?? this.titleStyle,
    subtitleStyle: subtitleStyle ?? this.subtitleStyle,
    durationStyle: durationStyle ?? this.durationStyle,
    sectionSubtitleStyle: sectionSubtitleStyle ?? this.sectionSubtitleStyle,
  );

  @override
  WorkoutCardTypographyTokens lerp(
    ThemeExtension<WorkoutCardTypographyTokens>? other,
    double t,
  ) {
    if (other is! WorkoutCardTypographyTokens) return this;
    return WorkoutCardTypographyTokens(
      titleStyle: TextStyle.lerp(titleStyle, other.titleStyle, t) ?? titleStyle,
      subtitleStyle:
          TextStyle.lerp(subtitleStyle, other.subtitleStyle, t) ??
          subtitleStyle,
      durationStyle:
          TextStyle.lerp(durationStyle, other.durationStyle, t) ??
          durationStyle,
      sectionSubtitleStyle:
          TextStyle.lerp(sectionSubtitleStyle, other.sectionSubtitleStyle, t) ??
          sectionSubtitleStyle,
    );
  }
}

@immutable
class WorkoutCardOverlayTokens
    extends ThemeExtension<WorkoutCardOverlayTokens> {
  const WorkoutCardOverlayTokens({
    required this.begin,
    required this.end,
    required this.stops,
    required this.colors,
  });

  final Alignment begin;
  final Alignment end;
  final List<double> stops;
  final List<Color> colors;

  static const WorkoutCardOverlayTokens light = WorkoutCardOverlayTokens(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    stops: [0.0, 0.8],
    colors: [Color(0xCC1A1A1A), Color(0x001A1A1A)],
  );

  LinearGradient get gradient =>
      LinearGradient(begin: begin, end: end, stops: stops, colors: colors);

  @override
  WorkoutCardOverlayTokens copyWith({
    Alignment? begin,
    Alignment? end,
    List<double>? stops,
    List<Color>? colors,
  }) => WorkoutCardOverlayTokens(
    begin: begin ?? this.begin,
    end: end ?? this.end,
    stops: stops ?? this.stops,
    colors: colors ?? this.colors,
  );

  @override
  WorkoutCardOverlayTokens lerp(
    ThemeExtension<WorkoutCardOverlayTokens>? other,
    double t,
  ) {
    if (other is! WorkoutCardOverlayTokens) return this;
    final Alignment? lerpedBegin = Alignment.lerp(begin, other.begin, t);
    final Alignment? lerpedEnd = Alignment.lerp(end, other.end, t);

    final List<double> lerpedStops = _lerpDoubleList(stops, other.stops, t);
    final List<Color> lerpedColors = _lerpColorList(colors, other.colors, t);

    return WorkoutCardOverlayTokens(
      begin: lerpedBegin ?? begin,
      end: lerpedEnd ?? end,
      stops: lerpedStops,
      colors: lerpedColors,
    );
  }
}

@immutable
class RecommendationCardOverlayTokens
    extends ThemeExtension<RecommendationCardOverlayTokens> {
  const RecommendationCardOverlayTokens({
    required this.begin,
    required this.end,
    required this.stops,
    required this.colors,
  });

  final Alignment begin;
  final Alignment end;
  final List<double> stops;
  final List<Color> colors;

  static const RecommendationCardOverlayTokens light =
      RecommendationCardOverlayTokens(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: [0.4991, 0.9105],
        colors: [Color(0x001A1A1A), Color(0xCC1A1A1A)],
      );

  LinearGradient get gradient =>
      LinearGradient(begin: begin, end: end, stops: stops, colors: colors);

  @override
  RecommendationCardOverlayTokens copyWith({
    Alignment? begin,
    Alignment? end,
    List<double>? stops,
    List<Color>? colors,
  }) => RecommendationCardOverlayTokens(
    begin: begin ?? this.begin,
    end: end ?? this.end,
    stops: stops ?? this.stops,
    colors: colors ?? this.colors,
  );

  @override
  RecommendationCardOverlayTokens lerp(
    ThemeExtension<RecommendationCardOverlayTokens>? other,
    double t,
  ) {
    if (other is! RecommendationCardOverlayTokens) return this;
    final Alignment? lerpedBegin = Alignment.lerp(begin, other.begin, t);
    final Alignment? lerpedEnd = Alignment.lerp(end, other.end, t);

    final List<double> lerpedStops = _lerpDoubleList(stops, other.stops, t);
    final List<Color> lerpedColors = _lerpColorList(colors, other.colors, t);

    return RecommendationCardOverlayTokens(
      begin: lerpedBegin ?? begin,
      end: lerpedEnd ?? end,
      stops: lerpedStops,
      colors: lerpedColors,
    );
  }
}
