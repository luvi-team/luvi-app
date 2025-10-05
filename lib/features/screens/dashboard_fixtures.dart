import 'package:flutter/foundation.dart' hide Category;
import 'package:luvi_app/core/design_tokens/assets.dart';

import 'dashboard_vm.dart';

/// Props/Contracts for Dashboard components (audit-backed).
/// See docs/ui/contracts/dashboard_state.md for field mappings and behavior.

@immutable
class HeaderProps {
  final String userName;
  final String dateText;
  final String cyclePhaseText;

  const HeaderProps({
    required this.userName,
    required this.dateText,
    required this.cyclePhaseText,
  });
}

@immutable
class HeroCardProps {
  final String programTitle;
  final String openCountText;
  final double progressRatio; // 0.0–1.0

  const HeroCardProps({
    required this.programTitle,
    required this.openCountText,
    required this.progressRatio,
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
class DashboardFixtureState {
  final HeaderProps header;
  final HeroCardProps heroCard;
  final List<CategoryProps> categories;
  final List<RecommendationProps> recommendations;
  final BottomNavProps bottomNav;

  const DashboardFixtureState({
    required this.header,
    required this.heroCard,
    required this.categories,
    required this.recommendations,
    required this.bottomNav,
  });

  /// Convenience forwards so the view model bridge stays explicit in fixtures.
  String get userName => header.userName;

  String get dateText => header.dateText;

  String get cyclePhaseText => header.cyclePhaseText;

  double get cycleProgressRatio => heroCard.progressRatio;

  /// Default CTA mirrors the "Zurück zum Training" copy in the hero card.
  /// See docs/ui/contracts/dashboard_state.md (HeroCtaState → label mapping).
  HeroCtaState get heroCta => HeroCtaState.resumeActiveWorkout;

  /// Active category chip shown with gold highlight in UI mocks.
  /// See docs/ui/contracts/dashboard_state.md (Category → chip highlight + future reco filter).
  Category get selectedCategory => Category.training;
}

/// Fixture states for Dashboard (3 variants: default, withNotifications, emptyRecommendations).
/// Each variant exercises different UI states documented in docs/ui/contracts/dashboard_state.md.
class DashboardFixtures {
  /// Variant A – Baseline: greeting + progress ring, CTA "Zurück zum Training",
  /// gold-highlighted Training chip, Home tab active.
  /// See docs/ui/contracts/dashboard_state.md for field → UI mappings.
  static DashboardFixtureState defaultState() {
    return DashboardFixtureState(
      header: const HeaderProps(
        userName: 'Sarah',
        dateText: 'Heute, 28. Sept',
        cyclePhaseText: 'Folikelphase',
      ),
      heroCard: const HeroCardProps(
        programTitle: 'Kraft - Ganzkörper',
        openCountText: '12 Übungen offen',
        progressRatio: 0.25,
      ),
      categories: [
        CategoryProps(
          iconPath: Assets.icons.catTraining,
          label: 'Training',
          isSelected: true,
        ),
        CategoryProps(
          iconPath: Assets.icons.catNutrition,
          label: 'Ernährung',
        ),
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
      bottomNav: const BottomNavProps(
        selectedIndex: 0,
        items: ['Home', 'Flower', 'Social', 'Account'], // 'Home' = first tab (index 0)
      ),
    );
  }

  /// Variant B – Notification badge: identical data, but activates bell indicator.
  static DashboardFixtureState withNotifications() {
    final base = defaultState();
    return DashboardFixtureState(
      header: base.header,
      heroCard: base.heroCard,
      categories: base.categories,
      recommendations: base.recommendations,
      bottomNav: BottomNavProps(
        selectedIndex: base.bottomNav.selectedIndex,
        items: base.bottomNav.items,
        hasNotifications: true,
      ),
    );
  }

  /// Variant C – Empty recommendations: surfaces placeholder state under cards row.
  static DashboardFixtureState emptyRecommendations() {
    final base = defaultState();
    return DashboardFixtureState(
      header: base.header,
      heroCard: base.heroCard,
      categories: base.categories,
      recommendations: const [], // empty
      bottomNav: base.bottomNav,
    );
  }
}
