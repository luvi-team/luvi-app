// ignore_for_file: unnecessary_library_name

@TestOn('vm')
library remote_loader_io_test;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/features/legal/remote_loader_io.dart';

Uri _buildUri(HttpServer server) {
  final host = server.address.host;
  return Uri.parse('http://$host:${server.port}/legal.md');
}

void main() {
  group('fetchRemoteMarkdown (IO)', () {
    test('returns body when server responds with 2xx', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) {
        request.response
          ..statusCode = 200
          ..write('## Terms of Service');
        request.response.close();
      });

      final result = await fetchRemoteMarkdown(
        _buildUri(server),
        timeout: const Duration(seconds: 1),
      );

      expect(result, '## Terms of Service');
    });

    test('returns null when server replies with error status', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) {
        request.response.statusCode = 503;
        request.response.close();
      });

      final result = await fetchRemoteMarkdown(
        _buildUri(server),
        timeout: const Duration(seconds: 1),
      );

      expect(result, isNull);
    });

    test('returns null when the request exceeds timeout', () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      addTearDown(() => server.close(force: true));
      server.listen((request) async {
        await Future<void>.delayed(const Duration(milliseconds: 200));
        request.response
          ..statusCode = 200
          ..write('## Privacy Policy');
        await request.response.close();
      });

      final result = await fetchRemoteMarkdown(
        _buildUri(server),
        timeout: const Duration(milliseconds: 50),
      );

      expect(result, isNull);
    });
  });
}
