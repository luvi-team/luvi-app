// ignore_for_file: unnecessary_library_name

@TestOn('browser')
library remote_loader_web_test;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:luvi_app/features/legal/remote_loader_web.dart';

void main() {
  final uri = Uri.parse('https://example.com/legal.md');

  setUp(() {
    debugResetBrowserClientFactory();
  });

  tearDown(() {
    debugResetBrowserClientFactory();
  });

  group('fetchRemoteMarkdown (Web)', () {
    test('returns response body for 2xx status', () async {
      debugOverrideBrowserClientFactory(
        () => MockClient((request) async {
          expect(request.url, uri);
          return http.Response('## Remote Privacy', 200);
        }),
      );

      final result = await fetchRemoteMarkdown(uri);

      expect(result, '## Remote Privacy');
    });

    test('returns null for non-2xx status', () async {
      debugOverrideBrowserClientFactory(
        () => MockClient((request) async => http.Response('nope', 500)),
      );

      final result = await fetchRemoteMarkdown(uri);

      expect(result, isNull);
    });

    test('returns null when client throws', () async {
      debugOverrideBrowserClientFactory(
        () => MockClient((request) async => throw TimeoutException('slow')),
      );

      final result = await fetchRemoteMarkdown(uri);

      expect(result, isNull);
    });
  });
}
