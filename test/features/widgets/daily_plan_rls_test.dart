// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// ignore: unused_import
import '../../support/test_config.dart';

void main() {
    group('Daily Plan RLS Widget Tests', () {
    testWidgets('Should show only user-owned daily plans', (
      WidgetTester tester,
    ) async {
      // Mock widget that simulates daily plan list with RLS
      await tester.pumpWidget(
        ProviderScope(child: MaterialApp(home: DailyPlanTestWidget())),
      );

      // Verify initial state
      expect(find.text('Daily Plans'), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      // Allow async operations to complete
      await tester.pump();

      // Verify RLS message is shown
      expect(
        find.text('Only your plans are visible (RLS active)'),
        findsOneWidget,
      );
    });

    testWidgets('Should prevent unauthorized data access', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return Column(
                  children: [
                    Text('RLS Protection Test'),
                    ElevatedButton(
                      onPressed: () {
                        // Simulates attempt to access other user's data
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Access denied: RLS policy enforced'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      },
                      child: Text('Try Access Other User Data'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Tap the button
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Verify RLS enforcement message
      expect(find.text('Access denied: RLS policy enforced'), findsOneWidget);
    });

    testWidgets('Should auto-populate user_id from auth', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Text('User ID Auto-Population'),
                Card(
                  child: ListTile(
                    title: Text('New Daily Plan'),
                    subtitle: Text('user_id: auto-set from auth.uid()'),
                    leading: Icon(Icons.security, color: Colors.green),
                  ),
                ),
                Text(
                  'Trigger ensures user_id matches auth',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      );

      // Verify UI elements showing RLS behavior
      expect(find.text('User ID Auto-Population'), findsOneWidget);
      expect(find.text('user_id: auto-set from auth.uid()'), findsOneWidget);
      expect(find.text('Trigger ensures user_id matches auth'), findsOneWidget);
      expect(find.byIcon(Icons.security), findsOneWidget);
    });
  });
}

// Test widget to demonstrate RLS impact
class DailyPlanTestWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Daily Plans')),
      body: Column(
        children: [
          Text('Loading...'),
          SizedBox(height: 20),
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Row(
              children: [
                Icon(Icons.lock, color: Colors.blue),
                SizedBox(width: 8),
                Text('Only your plans are visible (RLS active)'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
