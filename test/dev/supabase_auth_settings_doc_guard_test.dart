import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/app_links.dart';

void main() {
  test('supabase auth settings doc lists the mobile callback URI', () {
    final file = File('docs/dev/supabase_auth_settings.md');
    expect(
      file.existsSync(),
      isTrue,
      reason: 'docs/dev/supabase_auth_settings.md must exist to pass audits.',
    );
    final contents = file.readAsStringSync();
    expect(
      contents.contains(AppLinks.oauthRedirectUri),
      isTrue,
      reason:
          'Keep docs/dev/supabase_auth_settings.md in sync with AppLinks.oauthRedirectUri.',
    );
  });
}
