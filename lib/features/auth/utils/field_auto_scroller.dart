import 'package:flutter/material.dart';

/// Small helper that ensures a field keyed by [targetKey]
/// becomes visible by using the owning scroll controller.
class FieldAutoScroller {
  FieldAutoScroller(this._controller);

  final ScrollController _controller;

  Future<void> ensureVisible(GlobalKey targetKey) async {
    final context = targetKey.currentContext;
    if (context == null) return;

    await Future<void>.microtask(() {});
    if (!_controller.hasClients || !context.mounted) return;

    await Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
    );
  }
}
