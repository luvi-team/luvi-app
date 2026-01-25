import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/dashboard/domain/models/category.dart';
import 'package:luvi_app/features/dashboard/domain/models/recommendation.dart';

void main() {
  group('categoryFromTag', () {
    group('training tags', () {
      test('maps Kraft to training (case insensitive)', () {
        expect(categoryFromTag('Kraft'), Category.training);
        expect(categoryFromTag('kraft'), Category.training);
        expect(categoryFromTag('KRAFT'), Category.training);
      });

      test('maps cardio to training', () {
        expect(categoryFromTag('cardio'), Category.training);
        expect(categoryFromTag('Cardio'), Category.training);
      });

      test('maps hiit to training', () {
        expect(categoryFromTag('hiit'), Category.training);
        expect(categoryFromTag('HIIT'), Category.training);
      });
    });

    group('nutrition tags', () {
      test('maps supplements to nutrition', () {
        expect(categoryFromTag('supplements'), Category.nutrition);
        expect(categoryFromTag('Supplements'), Category.nutrition);
      });

      test('maps makros to nutrition', () {
        expect(categoryFromTag('makros'), Category.nutrition);
        expect(categoryFromTag('Makros'), Category.nutrition);
      });

      test('maps tagebuch to nutrition', () {
        expect(categoryFromTag('tagebuch'), Category.nutrition);
        expect(categoryFromTag('Tagebuch'), Category.nutrition);
      });

      test('maps rezepte to nutrition', () {
        expect(categoryFromTag('rezepte'), Category.nutrition);
        expect(categoryFromTag('Rezepte'), Category.nutrition);
      });
    });

    group('regeneration tags', () {
      test('maps achtsamkeit to regeneration', () {
        expect(categoryFromTag('achtsamkeit'), Category.regeneration);
        expect(categoryFromTag('Achtsamkeit'), Category.regeneration);
      });

      test('maps beweglichkeit to regeneration', () {
        expect(categoryFromTag('beweglichkeit'), Category.regeneration);
        expect(categoryFromTag('Beweglichkeit'), Category.regeneration);
      });

      test('maps beauty to regeneration', () {
        expect(categoryFromTag('beauty'), Category.regeneration);
        expect(categoryFromTag('Beauty'), Category.regeneration);
      });

      test('maps schlaf to regeneration', () {
        expect(categoryFromTag('schlaf'), Category.regeneration);
        expect(categoryFromTag('Schlaf'), Category.regeneration);
      });
    });

    group('mindfulness tags', () {
      test('maps meditation to mindfulness', () {
        expect(categoryFromTag('meditation'), Category.mindfulness);
        expect(categoryFromTag('Meditation'), Category.mindfulness);
      });

      test('maps wellness to mindfulness', () {
        expect(categoryFromTag('wellness'), Category.mindfulness);
        expect(categoryFromTag('Wellness'), Category.mindfulness);
      });

      test('maps entspannung to mindfulness', () {
        expect(categoryFromTag('entspannung'), Category.mindfulness);
        expect(categoryFromTag('Entspannung'), Category.mindfulness);
      });
    });

    group('unmapped tags', () {
      test('returns null for unknown tag', () {
        expect(categoryFromTag('unknown'), isNull);
      });

      test('returns null for empty string', () {
        expect(categoryFromTag(''), isNull);
      });

      test('returns null for random text', () {
        expect(categoryFromTag('randomTag123'), isNull);
      });
    });

    group('whitespace handling', () {
      test('trims leading and trailing spaces', () {
        expect(categoryFromTag('  kraft  '), Category.training);
        expect(categoryFromTag(' cardio '), Category.training);
      });

      test('trims tabs and newlines', () {
        expect(categoryFromTag('\tkraft\n'), Category.training);
        expect(categoryFromTag('\n\tmeditation\t\n'), Category.mindfulness);
      });
    });
  });
}
