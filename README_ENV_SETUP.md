# Environment Variables Setup for Supabase

## Overview
Your Flutter app now uses environment variables to securely manage Supabase configuration using `flutter_dotenv`.

## Files Created/Updated

### 1. Environment File: `.env.development`
```env
SUPA_URL=https://cwloioweaqvhibuzdwpi.supabase.co
SUPA_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImN3bG9pb3dlYXF2aGlidXpkd3BpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5NzU0MzMsImV4cCI6MjA3MjU1MTQzM30.5PE7q2taSX2AA83GxLzk95J6u_fA3otatAyxTt1Daq8
```

### 2. Updated SupabaseService (`lib/services/supabase_service.dart`)
```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseService {
  static SupabaseClient get client => Supabase.instance.client;

  /// Initialize Supabase from environment variables
  static Future<void> initializeFromEnv() async {
    final url = dotenv.env['SUPA_URL'] ?? '';
    final anon = dotenv.env['SUPA_ANON_KEY'] ?? '';
    if (url.isEmpty || anon.isEmpty) {
      throw Exception('Missing SUPA_URL or SUPA_ANON_KEY in .env file');
    }
    await Supabase.initialize(url: url, anonKey: anon);
  }

  static bool get isAuthenticated => client.auth.currentUser != null;
  static User? get currentUser => client.auth.currentUser;

  /// Your improved upsert method
  static Future<Map<String, dynamic>?> upsertEmailPreferences({ 
    bool? newsletter 
  }) async {
    if (!isAuthenticated) throw Exception('User must be authenticated');
    final data = <String, dynamic>{'user_id': currentUser!.id};
    if (newsletter != null) data['newsletter'] = newsletter;
    final row = await client
        .from('email_preferences')
        .upsert(data, onConflict: 'user_id')
        .select()
        .single();
    return row;
  }

  static Future<Map<String, dynamic>?> getEmailPreferences() async {
    if (!isAuthenticated) throw Exception('User must be authenticated');
    final userId = currentUser!.id;
    return await client
        .from('email_preferences')
        .select()
        .eq('user_id', userId)
        .maybeSingle();
  }
}
```

### 3. Updated Dependencies (`pubspec.yaml`)
Added:
- `flutter_dotenv: ^5.1.0`
- Added `.env.development` to assets

### 4. Updated Main App (`lib/main.dart`)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: '.env.development');
  
  // Initialize Supabase from environment
  await SupabaseService.initializeFromEnv();
  
  runApp(const MyApp());
}
```

## Benefits of This Approach

1. **Security**: Credentials are not hardcoded in the source code
2. **Flexibility**: Easy to switch between different environments (dev/staging/prod)
3. **Clean Code**: Your implementation is concise and focused
4. **Error Handling**: Proper validation of environment variables
5. **Type Safety**: Clean, typed interface for Supabase operations

## Usage Examples

### Basic Email Preference Update
```dart
// Update newsletter preference
final result = await SupabaseService.upsertEmailPreferences(
  newsletter: true,
);
print('Updated preferences: $result');
```

### With Error Handling
```dart
try {
  final result = await SupabaseService.upsertEmailPreferences(
    newsletter: false,
  );
  print('Success: $result');
} catch (e) {
  print('Error: $e');
}
```

### Get Current Preferences
```dart
try {
  final preferences = await SupabaseService.getEmailPreferences();
  if (preferences != null) {
    print('Newsletter: ${preferences['newsletter']}');
  } else {
    print('No preferences found for user');
  }
} catch (e) {
  print('Error loading preferences: $e');
}
```

## Next Steps

1. **Authentication**: Implement sign-in/sign-up functionality
2. **Additional Environments**: Create `.env.production`, `.env.staging` files
3. **Extended Preferences**: Add more preference fields (promotions, updates, etc.)
4. **Testing**: Add unit tests for the service methods
5. **Error UI**: Improve error handling in the UI layer

## Security Note

Remember to:
- Add `.env.*` to your `.gitignore` file to prevent committing secrets
- Use different credentials for different environments
- Rotate keys regularly for production environments

The current setup is ready for development and testing!
