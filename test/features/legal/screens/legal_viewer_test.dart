import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/features/legal/screens/legal_viewer.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

void main() {
  final l10n =
      lookupAppLocalizations(AppLocalizations.supportedLocales.first);
  group('LegalViewer', () {
    const assetPath = 'assets/legal/privacy.md';
    final remoteUri = Uri.parse('https://legal.luvi.app/privacy');
    final fallbackBanner = l10n.legalViewerFallbackBanner;
    final errorText = l10n.documentLoadError;

    testWidgets(
      'renders remote markdown when fetch succeeds',
      (tester) async {
        final appLinks = _TestAppLinks(privacyPolicy: remoteUri);
        final requested = <Uri>[];

        Future<String?> remoteFetcher(
          Uri uri, {
          Duration timeout = const Duration(seconds: 10),
        }) async {
          requested.add(uri);
          return '# Remote Body';
        }

        await tester.pumpWidget(
          MaterialApp(
            home: LegalViewer.asset(
              assetPath,
              title: 'Privacy',
              appLinks: appLinks,
              assetBundle: _FakeAssetBundle(assets: const {
                assetPath: 'Fallback asset body',
              }),
              remoteMarkdownFetcher: remoteFetcher,
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.textContaining('Remote Body'), findsOneWidget);
        expect(find.text(fallbackBanner), findsNothing);
        expect(requested, equals([remoteUri]));
      },
    );

    testWidgets(
      'falls back to asset bundle and shows fallback banner',
      (tester) async {
        final appLinks = _TestAppLinks(privacyPolicy: remoteUri);
        final breadcrumbEvents = <String>[];

        Future<String?> failingFetcher(
          Uri uri, {
          Duration timeout = const Duration(seconds: 10),
        }) async {
          throw Exception('remote boom');
        }

        await tester.pumpWidget(
          MaterialApp(
            home: LegalViewer.asset(
              assetPath,
              title: 'Privacy',
              appLinks: appLinks,
              assetBundle: _FakeAssetBundle(assets: const {
                assetPath: 'Local Markdown from bundle',
              }),
              remoteMarkdownFetcher: failingFetcher,
              debugBreadcrumbHook: (event, {required data}) {
                breadcrumbEvents.add(event);
                expect(data['assetPath'], assetPath);
                expect(data['remoteUri'], remoteUri.toString());
              },
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.textContaining('Local Markdown'), findsOneWidget);
        expect(find.text(fallbackBanner), findsOneWidget);
        expect(breadcrumbEvents, contains('legal_viewer_fallback'));
      },
    );

    testWidgets(
      'treats empty remote response as failure and loads asset fallback',
      (tester) async {
        final appLinks = _TestAppLinks(privacyPolicy: remoteUri);
        final breadcrumbEvents = <String>[];
        final requested = <Uri>[];

        Future<String?> emptyFetcher(
          Uri uri, {
          Duration timeout = const Duration(seconds: 10),
        }) async {
          requested.add(uri);
          return '   ';
        }

        await tester.pumpWidget(
          MaterialApp(
            home: LegalViewer.asset(
              assetPath,
              title: 'Privacy',
              appLinks: appLinks,
              assetBundle: _FakeAssetBundle(assets: const {
                assetPath: 'Asset fallback body',
              }),
              remoteMarkdownFetcher: emptyFetcher,
              debugBreadcrumbHook: (event, {required data}) {
                breadcrumbEvents.add(event);
                expect(data['assetPath'], assetPath);
                expect(data['remoteUri'], remoteUri.toString());
              },
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.textContaining('Asset fallback body'), findsOneWidget);
        expect(find.text(fallbackBanner), findsOneWidget);
        expect(breadcrumbEvents, contains('legal_viewer_fallback'));
        expect(requested, equals([remoteUri]));
      },
    );

    testWidgets(
      'surfaces error text when both remote and asset fail and exposes telemetry hook',
      (tester) async {
        final appLinks = _TestAppLinks(privacyPolicy: remoteUri);
        final exceptionEvents = <String>[];
        Object? capturedError;

        Future<String?> failingFetcher(
          Uri uri, {
          Duration timeout = const Duration(seconds: 10),
        }) async {
          throw StateError('network down');
        }

        await tester.pumpWidget(
          MaterialApp(
            home: LegalViewer.asset(
              assetPath,
              title: 'Privacy',
              appLinks: appLinks,
              assetBundle: _FakeAssetBundle(
                assets: const {},
                throwOnLoad: true,
              ),
              remoteMarkdownFetcher: failingFetcher,
              debugExceptionHook: (event,
                  {required error, required stack, required data}) {
                exceptionEvents.add(event);
                capturedError = error;
                expect(stack, isA<StackTrace>());
                expect(data['assetPath'], assetPath);
                expect(data['remoteUri'], remoteUri.toString());
              },
            ),
          ),
        );

        await tester.pump();
        await tester.pumpAndSettle();

        expect(find.text(errorText), findsOneWidget);
        expect(exceptionEvents, contains('legal_viewer_failed'));
        expect(capturedError, isA<FlutterError>());
      },
    );
  });
}

class _TestAppLinks extends AppLinksApi {
  final Uri _privacyPolicy;
  final Uri _terms;

  const _TestAppLinks({
    required Uri privacyPolicy,
    Uri? termsOfService,
  })  : _privacyPolicy = privacyPolicy,
        _terms = termsOfService ?? privacyPolicy;

  @override
  Uri get privacyPolicy => _privacyPolicy;

  @override
  Uri get termsOfService => _terms;

  @override
  bool isConfiguredUrl(Uri? uri) => true;
}

class _FakeAssetBundle extends CachingAssetBundle {
  final Map<String, String> assets;
  final bool throwOnLoad;

  _FakeAssetBundle({
    required this.assets,
    this.throwOnLoad = false,
  });

  @override
  Future<ByteData> load(String key) {
    throw UnimplementedError('Use loadString in tests');
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async {
    if (throwOnLoad) {
      throw FlutterError('Missing asset: $key');
    }
    final value = assets[key];
    if (value == null) {
      throw FlutterError('Missing asset: $key');
    }
    return value;
  }
}
