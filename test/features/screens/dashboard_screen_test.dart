import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/screens/dashboard_screen.dart';

void main() {
  group('DashboardScreen', () {
    testWidgets('renders Kategorien and Empfehlungen sections', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Check that both section titles are rendered
      expect(find.text('Kategorien'), findsOneWidget);
      expect(find.text('Empfehlungen'), findsOneWidget);
    });

    testWidgets('renders 4 category labels', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Check that all 4 category labels are present
      expect(find.text('Training'), findsOneWidget);
      expect(find.text('Ernährung'), findsOneWidget);
      expect(find.text('Regeneration'), findsOneWidget);
      expect(find.text('Achtsamkeit'), findsOneWidget);
    });

    testWidgets('renders horizontal list with 3 recommendation cards', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DashboardScreen(),
        ),
      );

      // Check that the 3 recommendation titles are present
      expect(find.text('Beine & Po'), findsOneWidget);
      expect(find.text('Rücken & Schulter'), findsOneWidget);
      expect(find.text('Ganzkörper'), findsOneWidget);
    });
  });
}
