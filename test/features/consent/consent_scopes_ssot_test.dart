import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:luvi_app/features/consent/domain/consent_types.dart';

void main() {
  late Set<String> jsonIds;
  late Set<String> jsonRequiredIds;

  setUpAll(() {
    final file = File('config/consent_scopes.json');
    expect(file.existsSync(), isTrue,
        reason: 'config/consent_scopes.json muss vorhanden sein');

    final jsonText = file.readAsStringSync();
    final List<dynamic> jsonList = jsonDecode(jsonText) as List<dynamic>;
    final List<Map<String, dynamic>> scopes =
        jsonList.cast<Map<String, dynamic>>();

    jsonIds = scopes.map((scope) => scope['id'] as String).toSet();
    jsonRequiredIds = scopes
        .where((scope) => scope['required'] == true)
        .map((scope) => scope['id'] as String)
        .toSet();
  });

  test('SSOT: ConsentScope enum matches config IDs', () {
    final dartIds = ConsentScope.values.map((scope) => scope.name).toSet();
    expect(dartIds, equals(jsonIds));
  });

  test('SSOT: required set matches config required flags', () {
    final dartRequiredIds =
        kRequiredConsentScopes.map((scope) => scope.name).toSet();
    expect(dartRequiredIds, equals(jsonRequiredIds));
  });
}
