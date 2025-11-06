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

    test('copyWith updates single field without mutating others', () {
      const vm = DashboardVM(
        cycleProgressRatio: 0.2,
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.mindfulness,
      );

      final updated = vm.copyWith(cycleProgressRatio: 0.42);

      expect(identical(updated, vm), isFalse);
      expect(updated.cycleProgressRatio, 0.42);
      expect(updated.heroCta, vm.heroCta);
      expect(updated.selectedCategory, vm.selectedCategory);
    });

    test('copyWith updates two fields while leaving others intact', () {
      const vm = DashboardVM(
        cycleProgressRatio: 0.6,
        heroCta: HeroCtaState.startNewWorkout,
        selectedCategory: Category.nutrition,
      );

      final updated = vm.copyWith(
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.mindfulness,
      );

      expect(identical(updated, vm), isFalse);
      expect(updated.heroCta, HeroCtaState.resumeActiveWorkout);
      expect(updated.selectedCategory, Category.mindfulness);
      expect(updated.cycleProgressRatio, vm.cycleProgressRatio);
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

    });

    test('cycleProgressRatio boundary values (0.0 and 1.0) remain intact and immutable', () {
      const vmZero = DashboardVM(
        cycleProgressRatio: 0.0,
        heroCta: HeroCtaState.startNewWorkout,
        selectedCategory: Category.training,
      );
      const vmOne = DashboardVM(
        cycleProgressRatio: 1.0,
        heroCta: HeroCtaState.resumeActiveWorkout,
        selectedCategory: Category.nutrition,
      );

      // Field assertions
      expect(vmZero.cycleProgressRatio, 0.0);
      expect(vmOne.cycleProgressRatio, 1.0);

      // copyWith preserves values (immutability semantics)
      final zeroCopy = vmZero.copyWith();
      final oneCopy = vmOne.copyWith();

      expect(zeroCopy.cycleProgressRatio, 0.0);
      expect(oneCopy.cycleProgressRatio, 1.0);
      expect(zeroCopy, vmZero);
      expect(oneCopy, vmOne);
      expect(identical(zeroCopy, vmZero), isFalse);
      expect(identical(oneCopy, vmOne), isFalse);
    });
  });
}
