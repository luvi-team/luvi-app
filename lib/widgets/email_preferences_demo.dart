import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class EmailPreferencesDemo extends StatefulWidget {
  const EmailPreferencesDemo({super.key});

  @override
  State<EmailPreferencesDemo> createState() => _EmailPreferencesDemoState();
}

class _EmailPreferencesDemoState extends State<EmailPreferencesDemo> {
  bool _isLoading = false;
  String? _statusMessage;
  Map<String, dynamic>? _currentPreferences;

  @override
  void initState() {
    super.initState();
    _loadCurrentPreferences();
  }

  Future<void> _loadCurrentPreferences() async {
    if (!SupabaseService.isAuthenticated) {
      setState(() {
        _statusMessage = 'User not authenticated';
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _statusMessage = null;
      });

      final preferences = await SupabaseService.getEmailPreferences();

      setState(() {
        _currentPreferences = preferences;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _statusMessage = 'Error loading preferences: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNewsletterPreference(bool value) async {
    try {
      setState(() {
        _isLoading = true;
        _statusMessage = null;
      });

      // This is the improved version of your original code:
      final result = await SupabaseService.upsertEmailPreferences(
        newsletter: value,
      );

      setState(() {
        _currentPreferences = result;
        _isLoading = false;
        _statusMessage = 'Newsletter preference updated successfully!';
      });

      debugPrint('Upsert result: $result');
    } catch (e) {
      setState(() {
        _statusMessage = 'Error updating preference: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email Preferences Demo',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),

            if (_statusMessage != null)
              Container(
                padding: const EdgeInsets.all(8.0),
                margin: const EdgeInsets.only(bottom: 16.0),
                decoration: BoxDecoration(
                  color: _statusMessage!.contains('Error')
                      ? Colors.red.withValues(alpha: 0.1)
                      : Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _statusMessage!.contains('Error')
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
                child: Text(
                  _statusMessage!,
                  style: TextStyle(
                    color: _statusMessage!.contains('Error')
                        ? Colors.red[800]
                        : Colors.green[800],
                  ),
                ),
              ),

            if (!SupabaseService.isAuthenticated)
              const Text('Please sign in to manage email preferences')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_currentPreferences != null) ...[
                    const Text('Current Preferences:'),
                    Text('User ID: ${_currentPreferences!['user_id']}'),
                    Text(
                      'Newsletter: ${_currentPreferences!['newsletter'] ?? 'Not set'}',
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      const Text('Newsletter Subscription: '),
                      Switch(
                        value: _currentPreferences?['newsletter'] ?? false,
                        onChanged: _isLoading
                            ? null
                            : _updateNewsletterPreference,
                      ),
                      if (_isLoading) ...[
                        const SizedBox(width: 16),
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _loadCurrentPreferences,
                    child: const Text('Refresh Preferences'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
