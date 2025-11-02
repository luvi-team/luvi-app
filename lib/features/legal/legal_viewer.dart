import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
            return const Center(
              child: Text(
                'Das Dokument konnte nicht geladen werden. Bitte versuchen Sie es später erneut.',
              ),
            );
          }
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Markdown(
              data: snap.data!,
              selectable: true,
              styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
                p: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
              ),
            ),
          );
        },
      ),
    );
  }
}
