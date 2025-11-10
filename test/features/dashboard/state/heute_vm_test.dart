import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/state/heute_vm.dart';

void main() {
  group('DashboardVM', () {
    test('copyWith creates a new instance with requested overrides', () {
      const vm = DashboardVM(
        cycleProgressRatio: 0.35,
        heroCta: HeroCtaState.startNewWorkout,
        selectedCategory: Category.training,
      );

      final updated = vm.copyWith(
        cycleProgressRatio: 0.5,
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.mindfulness,
      );

      expect(identical(updated, vm), isFalse);
      expect(updated.cycleProgressRatio, 0.5);
      expect(updated.heroCta, HeroCtaState.resumeActiveWorkout);
      expect(updated.selectedCategory, Category.mindfulness);
      expect(vm.cycleProgressRatio, 0.35);
      expect(vm.heroCta, HeroCtaState.startNewWorkout);
      expect(vm.selectedCategory, Category.training);
    });

    test('copyWith without overrides keeps values but returns new object', () {
      const vm = DashboardVM(
        cycleProgressRatio: 0.6,
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.nutrition,
      );

      final sameValues = vm.copyWith();

      expect(sameValues, vm);
      expect(identical(sameValues, vm), isFalse);
    });

    test('== and hashCode use value semantics', () {
      const base = DashboardVM(
        cycleProgressRatio: 0.2,
        heroCta: HeroCtaState.startNewWorkout,
        selectedCategory: Category.regeneration,
      );
      const same = DashboardVM(
        cycleProgressRatio: 0.2,
        heroCta: HeroCtaState.startNewWorkout,
        selectedCategory: Category.regeneration,
      );
      const different = DashboardVM(
        cycleProgressRatio: 0.9,
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.training,
      );

      expect(base, same);
      expect(base.hashCode, same.hashCode);
      expect(base == different, isFalse);
      expect(base.hashCode == different.hashCode, isFalse);
    });
  });
}
