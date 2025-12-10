import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('password recovery email template doc stays in sync', () {
    final file =
        File('docs/dev/supabase_email_templates_password_recovery.md');
    expect(
      file.existsSync(),
      isTrue,
      reason:
          'docs/dev/supabase_email_templates_password_recovery.md muss gepflegt werden.',
    );

    final contents = file.readAsStringSync().replaceAll('\r\n', '\n');
    const expectedSubject = 'LUVI – Setze dein Passwort zurück';
    expect(
      contents.contains(expectedSubject),
      isTrue,
      reason: 'Betreff aus Supabase muss im Doc stehen.',
    );

    const bodyBlock = '''Hi {{ .User.email }},

du (oder jemand anderes) hast angefragt, das Passwort deines LUVI Accounts zu ändern.
Tippe auf den Button, um dein neues Passwort festzulegen:

{{ .ConfirmationURL }}

Wenn du keine Änderung angefordert hast, kannst du diese Mail ignorieren. Dein Konto bleibt unverändert.

Herzliche Grüße
Team LUVI''';
    expect(
      contents.contains(bodyBlock),
      isTrue,
      reason: 'Mail-Body darf nicht ohne Repo-Update angepasst werden.',
    );
  });
}
