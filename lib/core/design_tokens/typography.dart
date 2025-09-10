/// Central typography tokens used by the app theme.
class TypeScale {
  TypeScale._();
  // Families (must match pubspec.yaml)
  static const playfair = 'Playfair Display';
  static const figtree = 'Figtree';
  static const inter = 'Inter';

  // Sizes & line-heights (from current design)
  // H1: 32 / 40
  static const h1Size = 32.0;
  static const h1Height = 40.0 / 32.0;
  // Body: 20 / 24
  static const bodySize = 20.0;
  static const bodyHeight = 24.0 / 20.0;
  // Button label: 20 / 24 (bold weight)
  static const labelSize = 20.0;
  static const labelHeight = 24.0 / 20.0;
  // Small/Skip: 17 / 25 (Inter Medium)
  static const smallSize = 17.0;
  static const smallHeight = 25.0 / 17.0;
}
