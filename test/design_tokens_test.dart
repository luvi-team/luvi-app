import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/design_tokens/tokens.dart';

void main() {
  group('LUVI Design Tokens', () {
    testWidgets('Theme provides correct colors and typography', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: LuviTokens.theme,
          home: Builder(
            builder: (context) {
              final tokens = LuviDesignTokens.of(context);
              return Scaffold(
                backgroundColor: tokens.surface,
                body: Column(
                  children: [
                    Text('H1 Test', style: tokens.h1),
                    Text('Body Test', style: tokens.body),
                    Text('Callout Test', style: tokens.callout),
                    Text('Caption Test', style: tokens.caption),
                    Container(
                      color: tokens.primary,
                      child: tokens.gap16,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      // Verify theme is applied
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.text('H1 Test'), findsOneWidget);
      expect(find.text('Body Test'), findsOneWidget);
      expect(find.text('Callout Test'), findsOneWidget);
      expect(find.text('Caption Test'), findsOneWidget);
    });

    test('FigmaVariableMapping contains all expected mappings', () {
      // Verify color mappings
      expect(FigmaVariableMapping.colors.containsKey('Grayscale/White'), true);
      expect(FigmaVariableMapping.colors.containsKey('Grayscale/Black'), true);
      expect(FigmaVariableMapping.colors.containsKey('Primary color/100'), true);
      
      // Verify typography mappings
      expect(FigmaVariableMapping.typography.containsKey('Heading/H1'), true);
      expect(FigmaVariableMapping.typography.containsKey('Regular klein'), true);
      expect(FigmaVariableMapping.typography.containsKey('Callout'), true);
      
      // Verify mapping values use Theme.of(context) pattern
      expect(
        FigmaVariableMapping.colors['Grayscale/White'], 
        'Theme.of(context).colorScheme.surface',
      );
      expect(
        FigmaVariableMapping.typography['Heading/H1'], 
        'Theme.of(context).textTheme.headlineLarge',
      );
    });
  });
}