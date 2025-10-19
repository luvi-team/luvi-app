import 'package:flutter/foundation.dart' hide Category;
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/date_utils.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';
import 'package:luvi_app/features/dashboard/domain/top_recommendation_props.dart';
import 'package:luvi_app/features/dashboard/domain/weekly_training_props.dart';
import 'package:luvi_app/features/dashboard/domain/training_stat_props.dart';
import 'package:luvi_app/features/dashboard/state/heute_vm.dart';

/// Props/Contracts for Heute screen components (audit-backed).
/// See docs/ui/contracts/dashboard_state.md for field mappings and behavior.

@immutable
class HeaderProps {
  const HeaderProps({
    required this.userName,
    required this.dateText,
    required this.phaseLabel,
  });

  final String userName;
  final String dateText;
  final String phaseLabel;

  HeaderProps copyWith({
    String? userName,
    String? dateText,
    String? phaseLabel,
  }) {
    return HeaderProps(
      userName: userName ?? this.userName,
      dateText: dateText ?? this.dateText,
      phaseLabel: phaseLabel ?? this.phaseLabel,
    );
  }
}

@immutable
class HeroCardProps {
  const HeroCardProps({
    required this.programTitle,
    required this.openCountText,
    required this.progressRatio,
    required this.dateText,
    required this.subtitle,
    this.ctaState = HeroCtaState.resumeActiveWorkout,
  }) : assert(
         progressRatio >= 0.0 && progressRatio <= 1.0,
         'progressRatio must be between 0.0 and 1.0',
       );

  final String programTitle;
  final String openCountText;
  final double progressRatio; // 0.0–1.0
  final String dateText;
  final String subtitle;
  final HeroCtaState ctaState;

  HeroCardProps copyWith({
    String? programTitle,
    String? openCountText,
    double? progressRatio,
    String? dateText,
    String? subtitle,
    HeroCtaState? ctaState,
  }) {
    final double nextProgress = progressRatio ?? this.progressRatio;
    assert(
      nextProgress >= 0.0 && nextProgress <= 1.0,
      'progressRatio must be between 0.0 and 1.0',
    );
    return HeroCardProps(
      programTitle: programTitle ?? this.programTitle,
      openCountText: openCountText ?? this.openCountText,
      progressRatio: nextProgress,
      dateText: dateText ?? this.dateText,
      subtitle: subtitle ?? this.subtitle,
      ctaState: ctaState ?? this.ctaState,
    );
  }
}

@immutable
class CategoryProps {
  const CategoryProps({
    required this.iconPath,
    required this.label,
    required this.category,
    this.isSelected = false,
  });

  final String iconPath;
  final String label;
  final Category category;
  final bool isSelected;

  CategoryProps copyWith({
    String? iconPath,
    String? label,
    Category? category,
    bool? isSelected,
  }) {
    return CategoryProps(
      iconPath: iconPath ?? this.iconPath,
      label: label ?? this.label,
      category: category ?? this.category,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

@immutable
class RecommendationProps {
  const RecommendationProps({
    required this.tag,
    required this.title,
    required this.imagePath,
    this.subtitle,
  });

  final String tag;
  final String title;
  final String imagePath;
  final String? subtitle;

  RecommendationProps copyWith({
    String? tag,
    String? title,
    String? imagePath,
    String? subtitle,
  }) {
    return RecommendationProps(
      tag: tag ?? this.tag,
      title: title ?? this.title,
      imagePath: imagePath ?? this.imagePath,
      subtitle: subtitle ?? this.subtitle,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is RecommendationProps &&
        other.tag == tag &&
        other.title == title &&
        other.imagePath == imagePath &&
        other.subtitle == subtitle;
  }

  @override
  int get hashCode => Object.hash(tag, title, imagePath, subtitle);
}

@immutable
class BottomNavProps {
  const BottomNavProps({
    required this.selectedIndex,
    required this.items,
    this.hasNotifications = false,
  });

  final int selectedIndex;
  final List<String> items;
  final bool hasNotifications;

  BottomNavProps copyWith({
    int? selectedIndex,
    List<String>? items,
    bool? hasNotifications,
  }) {
    return BottomNavProps(
      selectedIndex: selectedIndex ?? this.selectedIndex,
      items: items ?? this.items,
      hasNotifications: hasNotifications ?? this.hasNotifications,
    );
  }
}

@immutable
class WearableProps {
  const WearableProps({required this.connected});

  final bool connected;

  WearableProps copyWith({bool? connected}) {
    return WearableProps(connected: connected ?? this.connected);
  }
}

@immutable
class HeuteFixtureState {
  const HeuteFixtureState({
    required this.header,
    required this.heroCard,
    required this.topRecommendation,
    required this.weeklyTrainings,
    required this.categories,
    required this.recommendations,
    required this.nutritionRecommendations,
    required this.regenerationRecommendations,
    required this.trainingStats,
    required this.wearable,
    required this.bottomNav,
    required this.referenceDate,
    required this.cycleInfo,
  });

  final HeaderProps header;
  final HeroCardProps heroCard;
  final TopRecommendationProps topRecommendation;
  final List<WeeklyTrainingProps> weeklyTrainings;
  final List<CategoryProps> categories;
  final List<RecommendationProps> recommendations;
  final List<RecommendationProps> nutritionRecommendations;
  final List<RecommendationProps> regenerationRecommendations;
  final List<TrainingStatProps> trainingStats;
  final WearableProps wearable;
  final BottomNavProps bottomNav;
  final DateTime referenceDate;
  final CycleInfo cycleInfo;

  HeuteFixtureState copyWith({
    HeaderProps? header,
    HeroCardProps? heroCard,
    TopRecommendationProps? topRecommendation,
    List<WeeklyTrainingProps>? weeklyTrainings,
    List<CategoryProps>? categories,
    List<RecommendationProps>? recommendations,
    List<RecommendationProps>? nutritionRecommendations,
    List<RecommendationProps>? regenerationRecommendations,
    List<TrainingStatProps>? trainingStats,
    WearableProps? wearable,
    BottomNavProps? bottomNav,
    DateTime? referenceDate,
    CycleInfo? cycleInfo,
  }) {
    return HeuteFixtureState(
      header: header ?? this.header,
      heroCard: heroCard ?? this.heroCard,
      topRecommendation: topRecommendation ?? this.topRecommendation,
      weeklyTrainings: weeklyTrainings ?? this.weeklyTrainings,
      categories: categories ?? this.categories,
      recommendations: recommendations ?? this.recommendations,
      nutritionRecommendations:
          nutritionRecommendations ?? this.nutritionRecommendations,
      regenerationRecommendations:
          regenerationRecommendations ?? this.regenerationRecommendations,
      trainingStats: trainingStats ?? this.trainingStats,
      wearable: wearable ?? this.wearable,
      bottomNav: bottomNav ?? this.bottomNav,
      referenceDate: referenceDate ?? this.referenceDate,
      cycleInfo: cycleInfo ?? this.cycleInfo,
    );
  }

  /// Convenience forwards so the view model bridge stays explicit in fixtures.
  String get userName => header.userName;

  String get dateText => header.dateText;

  String get phaseLabel => header.phaseLabel;

  double get cycleProgressRatio => heroCard.progressRatio;

  /// Default CTA mirrors the "Zurück zum Training" copy in the hero card.
  /// See docs/ui/contracts/dashboard_state.md (HeroCtaState → label mapping).
  HeroCtaState get heroCta => heroCard.ctaState;

  /// Active category chip shown with gold highlight in UI mocks.
  /// See docs/ui/contracts/dashboard_state.md (Category → chip highlight + future reco filter).
  Category get selectedCategory {
    if (categories.isEmpty) {
      return Category.training;
    }
    final CategoryProps selected = categories.firstWhere(
      (category) => category.isSelected,
      orElse: () => categories.first,
    );
    return selected.category;
  }
}

/// Fixture states for Heute screen (3 variants: default, withNotifications, emptyRecommendations).
/// Each variant exercises different UI states documented in docs/ui/contracts/dashboard_state.md.
class HeuteFixtures {
  /// Variant A – Baseline: greeting + progress ring, CTA "Zurück zum Training",
  /// gold-highlighted Training chip, Home tab active.
  /// See docs/ui/contracts/dashboard_state.md for field → UI mappings.
  static HeuteFixtureState defaultState() {
    final today = DateTime(2023, 9, 28);
    final cycleInfo = CycleInfo(
      lastPeriod: DateTime(2023, 9, 16),
      cycleLength: 28,
      periodDuration: 5,
    );
    final phase = cycleInfo.phaseFor(today);
    final dateText = CycleDateUtils.formatTodayDe(today);

    return HeuteFixtureState(
      header: HeaderProps(
        userName: 'Sarah',
        dateText: dateText,
        phaseLabel: phase.label,
      ),
      heroCard: HeroCardProps(
        programTitle: 'Kraft - Ganzkörper',
        openCountText: '12 Übungen offen',
        progressRatio: 0.25,
        dateText: dateText,
        subtitle:
            'Wir starten heute ruhig und strukturiert - eine lockere Cardio Einheit hilft dir fokussiert zu bleiben...',
        ctaState: HeroCtaState.resumeActiveWorkout,
      ),
      topRecommendation: TopRecommendationProps(
        id: 'reco-shoulder-stretching',
        tag: '', // Empty tag -> conditional rendering hides "KRAFT"
        title: 'Shoulder Stretching',
        imagePath: Assets.images.recoGanzkoerper,
        badgeAssetPath: Assets.icons.syncBadge,
        duration: '15 Min',
      ),
      weeklyTrainings: [
        WeeklyTrainingProps(
          id: 'wkly-ganzkoerper',
          title: 'Ganzkörper\nKrafttraining',
          subtitle: 'Baue deine Basis auf',
          dayLabel: 'Tag 1',
          duration: '60 min',
          imagePath: Assets.images.recoGanzkoerper,
        ),
        WeeklyTrainingProps(
          id: 'wkly-hiit-cardio',
          title: 'HIIT\nCardio',
          subtitle: 'Steigere deine Ausdauer',
          duration: '45 min',
          imagePath: Assets.images.recoBeinePo,
          isCompleted: true,
        ),
        WeeklyTrainingProps(
          id: 'wkly-mobility',
          title: 'Mobility',
          subtitle: 'Beweglichkeit verbessern',
          duration: '30 min',
          imagePath: Assets.images.recoRueckenSchulter,
        ),
      ],
      categories: [
        CategoryProps(
          iconPath: Assets.icons.catTraining,
          label: 'Training',
          category: Category.training,
          isSelected: true,
        ),
        CategoryProps(
          iconPath: Assets.icons.catNutrition,
          label: 'Ernährung',
          category: Category.nutrition,
        ),
        CategoryProps(
          iconPath: Assets.icons.catRegeneration,
          label: 'Regeneration',
          category: Category.regeneration,
        ),
        CategoryProps(
          iconPath: Assets.icons.catMindfulness,
          label: 'Achtsamkeit',
          category: Category.mindfulness,
        ),
      ],
      recommendations: [
        RecommendationProps(
          tag: 'Kraft',
          title: 'Beine & Po',
          imagePath: Assets.images.recoBeinePo,
        ),
        RecommendationProps(
          tag: 'Kraft',
          title: 'Rücken & Schulter',
          imagePath: Assets.images.recoRueckenSchulter,
        ),
        RecommendationProps(
          tag: 'Cardio',
          title: 'Ganzkörper',
          imagePath: Assets.images.recoGanzkoerper,
        ),
      ],
      // TODO: Replace remaining placeholder (Ernährungstagebuch) with Figma-specific imagery.
      nutritionRecommendations: [
        RecommendationProps(
          tag: 'Supplements',
          title: 'Vitamin C',
          subtitle: 'Stärke dein Immunsystem',
          imagePath: Assets.images.strawberry,
        ),
        RecommendationProps(
          tag: 'Makros',
          title: 'Protein-Power',
          subtitle: 'Optimale Nährstoffverteilung',
          imagePath: Assets.images.roteruebe,
        ),
        RecommendationProps(
          tag: 'Tagebuch',
          title: 'Ernährungstagebuch',
          subtitle: 'Tracke deine Mahlzeiten',
          imagePath: Assets.images.recoRueckenSchulter,
        ),
      ],
      // TODO: Replace remaining placeholder (Hautpflege) with Figma-specific imagery.
      regenerationRecommendations: [
        RecommendationProps(
          tag: 'Achtsamkeit',
          title: 'Meditation',
          subtitle: 'Finde innere Ruhe',
          imagePath: Assets.images.meditation,
        ),
        RecommendationProps(
          tag: 'Beweglichkeit',
          title: 'Stretching',
          subtitle: 'Entspanne deine Muskeln',
          imagePath: Assets.images.stretching,
        ),
        RecommendationProps(
          tag: 'Beauty',
          title: 'Hautpflege',
          subtitle: 'Zyklusgerechte Pflege',
          imagePath: Assets.images.recoRueckenSchulter,
        ),
      ],
      trainingStats: [
        TrainingStatProps(
          label: 'Puls',
          value: 94,
          unit: 'bpm',
          iconAssetPath: Assets.icons.dashboard.heart,
          trend: [0.62, 0.58, 0.67, 0.71, 0.68],
          heartRateGlyphAsset: Assets.icons.dashboard.heartRateGlyph,
        ),
        TrainingStatProps(
          label: 'Verbrannte Energie',
          value: 500,
          unit: 'kcal',
          iconAssetPath: Assets.icons.dashboard.kcal,
          trend: [0.32, 0.45, 0.38, 0.52, 0.6],
        ),
        TrainingStatProps(
          label: 'Schritte',
          value: 2500,
          iconAssetPath: Assets.icons.dashboard.run,
          trend: [0.18, 0.24, 0.36, 0.4, 0.48],
        ),
      ],
      wearable: const WearableProps(connected: true),
      bottomNav: const BottomNavProps(
        selectedIndex: 0,
        items: [
          'Home',
          'Flower',
          'Social',
          'Account',
        ], // 'Home' = first tab (index 0)
      ),
      referenceDate: today,
      cycleInfo: cycleInfo,
    );
  }

  /// Variant B – Notification badge: identical data, but activates bell indicator.
  static HeuteFixtureState withNotifications() {
    final base = defaultState();
    return base.copyWith(
      weeklyTrainings: base.weeklyTrainings,
      nutritionRecommendations: base.nutritionRecommendations,
      regenerationRecommendations: base.regenerationRecommendations,
      bottomNav: base.bottomNav.copyWith(hasNotifications: true),
    );
  }

  /// Variant C – Empty recommendations: surfaces placeholder state under cards row.
  static HeuteFixtureState emptyRecommendations() {
    final base = defaultState();
    return base.copyWith(
      weeklyTrainings: base.weeklyTrainings,
      heroCard: base.heroCard.copyWith(ctaState: HeroCtaState.startNewWorkout),
      recommendations: const [],
      nutritionRecommendations: base.nutritionRecommendations,
      regenerationRecommendations: base.regenerationRecommendations,
    );
  }
}
