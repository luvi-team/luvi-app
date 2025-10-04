import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/assets.dart';

void main() {
  group('Assets paths', () {
    test('icons have correct paths', () {
      expect(Assets.icons.search, 'assets/icons/dashboard/icon.search.svg');
      expect(Assets.icons.notifications, 'assets/icons/dashboard/icon.notifications.svg');
      expect(Assets.icons.play, 'assets/icons/dashboard/icon.play.svg');
      expect(Assets.icons.catTraining, 'assets/icons/dashboard/icon.category.training.svg');
      expect(Assets.icons.catNutrition, 'assets/icons/dashboard/icon.category.nutrition.svg');
      expect(Assets.icons.catRegeneration, 'assets/icons/dashboard/icon.category.regeneration.svg');
      expect(Assets.icons.catMindfulness, 'assets/icons/dashboard/icon.category.mindfulness.svg');
      expect(Assets.icons.navFlower, 'assets/icons/dashboard/icon.nav.flower.svg');
      expect(Assets.icons.navSocial, 'assets/icons/dashboard/icon.nav.social.svg');
      expect(Assets.icons.navAccount, 'assets/icons/dashboard/icon.nav.account.svg');
      expect(Assets.icons.navChart, 'assets/icons/dashboard/icon.nav.chart.svg');
      expect(Assets.icons.cycleOutline, 'assets/icons/dashboard/icon.nav.cycle-outline.svg');
    });

    test('images have correct paths', () {
      expect(Assets.images.recoBeinePo, 'assets/images/dashboard/reco.beine_po.png');
      expect(Assets.images.recoRueckenSchulter, 'assets/images/dashboard/reco.ruecken_schulter.png');
      expect(Assets.images.recoGanzkoerper, 'assets/images/dashboard/reco.ganzkoerper.png');
    });
  });
}
