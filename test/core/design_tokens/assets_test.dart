import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';

void main() {
  group('Assets paths', () {
    test('icons have correct paths', () {
      expect(Assets.icons.search, 'assets/icons/dashboard/icon.search.svg');
      expect(
        Assets.icons.notifications,
        'assets/icons/dashboard/icon.notifications.svg',
      );
      expect(Assets.icons.play, 'assets/icons/dashboard/icon.play.svg');
      expect(
        Assets.icons.catTraining,
        'assets/icons/dashboard/icon.category.training.svg',
      );
      expect(
        Assets.icons.catNutrition,
        'assets/icons/dashboard/icon.category.nutrition.svg',
      );
      expect(
        Assets.icons.catRegeneration,
        'assets/icons/dashboard/icon.category.regeneration.svg',
      );
      expect(
        Assets.icons.catMindfulness,
        'assets/icons/dashboard/icon.category.mindfulness.svg',
      );

      // Bottom nav icons (5-tab design)
      expect(Assets.icons.navToday, 'assets/icons/dashboard/nav.today.svg');
      expect(Assets.icons.navCycle, 'assets/icons/dashboard/nav.cycle.svg');
      expect(Assets.icons.navSync, 'assets/icons/dashboard/nav.sync.svg');
      expect(Assets.icons.navPulse, 'assets/icons/dashboard/nav.pulse.svg');
      expect(Assets.icons.navProfile, 'assets/icons/dashboard/nav.profile.svg');

      // Optional/extras
      expect(
        Assets.icons.cycleOutline,
        'assets/icons/dashboard/icon.nav.cycle-outline.svg',
      );
    });

    test('images have correct paths', () {
      expect(
        Assets.images.recoBeinePo,
        'assets/images/dashboard/reco.beine_po.png',
      );
      expect(
        Assets.images.recoRueckenSchulter,
        'assets/images/dashboard/reco.ruecken_schulter.png',
      );
      expect(
        Assets.images.recoGanzkoerper,
        'assets/images/dashboard/reco.ganzkoerper.png',
      );
    });
  });
}
