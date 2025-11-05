import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/core/logging/logger.dart';

class LegalViewer extends StatefulWidget {
  final String assetPath;
  final String title;

  const LegalViewer.asset(
    this.assetPath, {
    super.key,
    required this.title,
  });

  @override
  State<LegalViewer> createState() => _LegalViewerState();
}

class _LegalViewerState extends State<LegalViewer> {
  late final Future<String> _documentFuture;

  @override
  void initState() {
    super.initState();
    _documentFuture = rootBundle.loadString(widget.assetPath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: FutureBuilder<String>(
        future: _documentFuture,
        builder: (context, snap) {
          if (snap.hasError) {
            // Log the underlying error for diagnostics
            log.e('Failed to load legal document from asset: ${widget.assetPath}', 
                  tag: 'legal_viewer', error: snap.error!, stack: snap.stackTrace);
            final l10n = AppLocalizations.of(context);
            final message =
                l10n?.documentLoadError ?? 'Document could not be loaded.';
            return Center(child: Text(message));
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final theme = Theme.of(context);
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Markdown(
              data: snap.data!,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(theme).copyWith(
                p: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
