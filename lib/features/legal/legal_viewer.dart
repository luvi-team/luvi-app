import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:luvi_app/core/analytics/telemetry.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/core/logging/logger.dart';

// Conditional remote loader: IO vs Web
import 'remote_loader_base.dart'
    if (dart.library.io) 'remote_loader_io.dart'
    if (dart.library.html) 'remote_loader_web.dart';

class LegalViewer extends StatefulWidget {
  final String assetPath;
  final String title;
  final AppLinksApi appLinks;

  const LegalViewer.asset(
    this.assetPath, {
    super.key,
    required this.title,
    this.appLinks = const ProdAppLinks(),
  });

  @override
  State<LegalViewer> createState() => _LegalViewerState();
}

class _LegalDocData {
  const _LegalDocData({required this.content, required this.usedFallback});
  final String content;
  final bool usedFallback; // true when remote failed and asset content shown
}

class _LegalViewerState extends State<LegalViewer> {
  late final Future<_LegalDocData> _documentFuture;
  Uri? _remoteUri; // Derived from asset path if available

  @override
  void initState() {
    super.initState();
    _remoteUri = _deriveRemoteUri(widget.assetPath);
    _documentFuture = _loadDocumentWithFallback(
      assetPath: widget.assetPath,
      remoteUri: _remoteUri,
    );
  }

  static const String _privacyAssetPath = 'assets/legal/privacy.md';
  static const String _termsAssetPath = 'assets/legal/terms.md';

  Uri? _deriveRemoteUri(String assetPath) {
    // Map known assets to configured remote URLs using injected AppLinks
    final appLinks = widget.appLinks;
    final normalized = assetPath.replaceAll('\\', '/');
    if (normalized == _privacyAssetPath) {
      final uri = appLinks.privacyPolicy;
      return appLinks.isConfiguredUrl(uri) ? uri : null;
    }
    if (normalized == _termsAssetPath) {
      final uri = appLinks.termsOfService;
      return appLinks.isConfiguredUrl(uri) ? uri : null;
    }
    return null;
  }

  Future<_LegalDocData> _loadDocumentWithFallback({
    required String assetPath,
    required Uri? remoteUri,
  }) async {
    // Try remote-first when a valid remoteUri is available and platform allows it
    if (remoteUri != null) {
      try {
        final remote = await fetchRemoteMarkdown(
          remoteUri,
          timeout: const Duration(seconds: 5),
        );
        if (remote != null) {
          return _LegalDocData(content: remote, usedFallback: false);
        }
      } catch (error, stack) {
        log.w(
          'Remote legal load failed; falling back to asset. uri=$remoteUri',
          tag: 'legal_viewer',
          error: error,
          stack: stack,
        );
        Telemetry.maybeBreadcrumb(
          'legal_viewer_fallback',
          data: {
            'assetPath': assetPath,
            'remoteUri': remoteUri.toString(),
            'platform': kIsWeb ? 'web' : 'io',
          },
        );
      }
    }

    // Fallback to bundled asset content
    try {
      final asset = await rootBundle.loadString(assetPath);
      return _LegalDocData(content: asset, usedFallback: remoteUri != null);
    } catch (error, stack) {
      // Both remote and local failed → bubble up as error for UI error view
      log.e(
        'Failed to load legal document from asset: $assetPath',
        tag: 'legal_viewer',
        error: error,
        stack: stack,
      );
      Telemetry.maybeCaptureException(
        'legal_viewer_failed',
        error: error,
        stack: stack,
        data: {
          'assetPath': assetPath,
          'remoteUri': remoteUri?.toString(),
        },
      );
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<_LegalDocData>(
        future: _documentFuture,
        builder: (context, snap) {
          final l10n = AppLocalizations.of(context);
          if (snap.hasError) {
            // Log the underlying error for diagnostics
            log.e(
              'Failed to load legal document: ${widget.assetPath}',
              tag: 'legal_viewer',
              error: snap.error!,
              stack: snap.stackTrace,
            );
            final message =
                l10n?.documentLoadError ?? 'Document could not be loaded.';
            return Center(child: Text(message));
          }
          if (!snap.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                semanticsLabel: 'Loading document',
              ),
            );
          }
          final theme = Theme.of(context);
          final doc = snap.data!;
          final children = <Widget>[];
          if (doc.usedFallback) {
            children.add(
              Semantics(
                label: l10n?.legalViewerFallbackBanner ??
                    'Remote unavailable — showing offline copy.',
                child: Container(
                  margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.amber.shade800),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          l10n?.legalViewerFallbackBanner ??
                              'Remote unavailable — showing offline copy.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.amber.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
          final content = Padding(
            padding: const EdgeInsets.all(16),
            child: Markdown(
              data: doc.content,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          );
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ...children,
              Expanded(child: content),
            ],
          );
        },
      ),
    );
  }
}
