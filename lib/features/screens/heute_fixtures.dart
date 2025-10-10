import 'package:flutter/foundation.dart' hide Category;
import 'package:luvi_app/core/design_tokens/assets.dart';
import 'package:luvi_app/features/cycle/domain/cycle.dart';
import 'package:luvi_app/features/cycle/domain/date_utils.dart';
import 'package:luvi_app/features/cycle/domain/phase.dart';

import 'package:luvi_app/features/dashboard/state/heute_vm.dart';

/// Props/Contracts for Heute screen components (audit-backed).
/// See docs/ui/contracts/dashboard_state.md for field mappings and behavior.

@immutable
class HeaderProps {
  final String userName;
  final String dateText;
  final String phaseLabel;

  const HeaderProps({
    required this.userName,
    required this.dateText,
    required this.phaseLabel,
  });
}

@immutable
class HeroCardProps {
  final String programTitle;
  final String openCountText;
  final double progressRatio; // 0.0–1.0
  final String dateText;
  final String subtitle;

  const HeroCardProps({
    required this.programTitle,
    required this.openCountText,
    required this.progressRatio,
    required this.dateText,
    required this.subtitle,
  });
}

@immutable
class CategoryProps {
  final String iconPath;
  final String label;
  final bool isSelected;

  const CategoryProps({
    required this.iconPath,
    required this.label,
    this.isSelected = false,
  });
}

@immutable
class RecommendationProps {
  final String tag;
  final String title;
  final String imagePath;

  const RecommendationProps({
    required this.tag,
    required this.title,
    required this.imagePath,
  });
}

@immutable
class TopRecommendationProps {
  final String id;
  final String tag;
  final String title;
  final String imagePath;
  final String badgeAssetPath;
  final bool fromLuviSync;
  final String? duration;

  const TopRecommendationProps({
    required this.id,
    required this.tag,
    required this.title,
    required this.imagePath,
    required this.badgeAssetPath,
    this.fromLuviSync = true,
    this.duration,
  });
}

@immutable
class BottomNavProps {
  final int selectedIndex;
  final List<String> items;
  final bool hasNotifications;

  const BottomNavProps({
    required this.selectedIndex,
    required this.items,
    this.hasNotifications = false,
  });
}

@immutable
class TrainingStatProps {
  final String label;
  final num value;
  final String iconAssetPath;
  final String? unit;
  final List<double> trend;
  final String? heartRateGlyphAsset;

  const TrainingStatProps({
    required this.label,
    required this.value,
    required this.iconAssetPath,
    this.unit,
    this.trend = const [],
    this.heartRateGlyphAsset,
  });
}

@immutable
class WearableProps {
  final bool connected;

  const WearableProps({required this.connected});
}

@immutable
class HeuteFixtureState {
  final HeaderProps header;
  final HeroCardProps heroCard;
  final TopRecommendationProps topRecommendation;
  final List<CategoryProps> categories;
  final List<RecommendationProps> recommendations;
  final List<TrainingStatProps> trainingStats;
  final WearableProps wearable;
  final BottomNavProps bottomNav;
  final DateTime referenceDate;
  final CycleInfo cycleInfo;

  const HeuteFixtureState({
    required this.header,
    required this.heroCard,
    required this.topRecommendation,
    required this.categories,
    required this.recommendations,
    required this.trainingStats,
    required this.wearable,
    required this.bottomNav,
    required this.referenceDate,
    required this.cycleInfo,
  });

  /// Convenience forwards so the view model bridge stays explicit in fixtures.
  String get userName => header.userName;

  String get dateText => header.dateText;

  String get phaseLabel => header.phaseLabel;

  double get cycleProgressRatio => heroCard.progressRatio;

  /// Default CTA mirrors the "Zurück zum Training" copy in the hero card.
  /// See docs/ui/contracts/dashboard_state.md (HeroCtaState → label mapping).
  HeroCtaState get heroCta => HeroCtaState.resumeActiveWorkout;

  /// Active category chip shown with gold highlight in UI mocks.
  /// See docs/ui/contracts/dashboard_state.md (Category → chip highlight + future reco filter).
  Category get selectedCategory => Category.training;
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
      ),
      topRecommendation: TopRecommendationProps(
        id: 'reco-shoulder-stretching',
        tag: '', // Empty tag -> conditional rendering hides "KRAFT"
        title: 'Shoulder Stretching',
        imagePath: Assets.images.recoGanzkoerper,
        badgeAssetPath: Assets.icons.syncBadge,
        duration: '15 Min',
      ),
      categories: [
        CategoryProps(
          iconPath: Assets.icons.catTraining,
          label: 'Training',
          isSelected: true,
        ),
        CategoryProps(iconPath: Assets.icons.catNutrition, label: 'Ernährung'),
        CategoryProps(
          iconPath: Assets.icons.catRegeneration,
          label: 'Regeneration',
        ),
        CategoryProps(
          iconPath: Assets.icons.catMindfulness,
          label: 'Achtsamkeit',
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
    return HeuteFixtureState(
      header: base.header,
      heroCard: base.heroCard,
      topRecommendation: base.topRecommendation,
      categories: base.categories,
      recommendations: base.recommendations,
      trainingStats: base.trainingStats,
      wearable: base.wearable,
      bottomNav: BottomNavProps(
        selectedIndex: base.bottomNav.selectedIndex,
        items: base.bottomNav.items,
        hasNotifications: true,
      ),
      referenceDate: base.referenceDate,
      cycleInfo: base.cycleInfo,
    );
  }

  /// Variant C – Empty recommendations: surfaces placeholder state under cards row.
  static HeuteFixtureState emptyRecommendations() {
    final base = defaultState();
    return HeuteFixtureState(
      header: base.header,
      heroCard: base.heroCard,
      topRecommendation: base.topRecommendation,
      categories: base.categories,
      recommendations: const [], // empty
      trainingStats: base.trainingStats,
      wearable: base.wearable,
      bottomNav: base.bottomNav,
      referenceDate: base.referenceDate,
      cycleInfo: base.cycleInfo,
    );
  }
}
