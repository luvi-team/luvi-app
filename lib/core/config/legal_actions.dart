/// Legal link openers - Core helpers without feature imports.
///
/// These functions open legal documents (Privacy, Terms) either externally
/// via url_launcher or navigate to in-app fallback routes.
///
/// Guardrail: This file is in lib/core/ and must NOT import lib/features/**.
/// The in-app fallback uses GoRouter navigation to legal routes defined in
/// lib/router.dart (which IS allowed to import features).
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:luvi_app/core/config/app_links.dart';
import 'package:luvi_app/core/logging/logger.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/core/utils/run_catching.dart' show sanitizeError;

/// Opens the privacy policy document.
///
/// Attempts to launch the configured external URL first.
/// Falls back to in-app route [RoutePaths.legalPrivacy] if:
/// - URL is not configured/valid
/// - External launch fails
///
/// Requires [WidgetRef] to access [appLinksProvider].
Future<void> openPrivacy(BuildContext context, WidgetRef ref) async {
  final appLinks = ref.read(appLinksProvider);
  await _openLegalLink(
    context,
    uri: appLinks.privacyPolicy,
    isValid: appLinks.hasValidPrivacy,
    fallbackRoute: RoutePaths.legalPrivacy,
    logTag: 'privacy',
  );
}

/// Opens the terms of service document.
///
/// Attempts to launch the configured external URL first.
/// Falls back to in-app route [RoutePaths.legalTerms] if:
/// - URL is not configured/valid
/// - External launch fails
///
/// Requires [WidgetRef] to access [appLinksProvider].
Future<void> openTerms(BuildContext context, WidgetRef ref) async {
  final appLinks = ref.read(appLinksProvider);
  await _openLegalLink(
    context,
    uri: appLinks.termsOfService,
    isValid: appLinks.hasValidTerms,
    fallbackRoute: RoutePaths.legalTerms,
    logTag: 'terms',
  );
}

/// Internal helper to open a legal link externally or fall back to in-app route.
Future<void> _openLegalLink(
  BuildContext context, {
  required Uri uri,
  required bool isValid,
  required String fallbackRoute,
  required String logTag,
}) async {
  // Try external launch if URL is valid
  if (isValid) {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (ok) return;
    } catch (error, stackTrace) {
      log.w(
        'legal_link_launch_failed',
        tag: logTag,
        error: sanitizeError(error) ?? error.runtimeType,
        stack: stackTrace,
      );
      // Fall through to in-app fallback
    }
  }

  // Fallback to in-app route
  if (!context.mounted) return;
  context.go(fallbackRoute);
}
