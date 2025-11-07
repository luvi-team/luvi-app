import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';
import 'package:luvi_app/features/consent/config/consent_config.dart';
import 'package:luvi_app/core/analytics/analytics.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

class ConsentButton extends ConsumerStatefulWidget {
  const ConsentButton({super.key});

  @override
  ConsumerState<ConsentButton> createState() => _ConsentButtonState();
}

class _ConsentButtonState extends ConsumerState<ConsentButton> {
  bool _isLoading = false;

  /// Categorizes exceptions into generic error types to avoid leaking
  /// internal class names (e.g., _InternalSupabaseAuthException).
  /// Returns a safe, user-facing error category string.
  String _categorizeError(Object error) {
    // Network-related errors
    if (error is SocketException || error is IOException) {
      return 'network_error';
    }
    // Timeout
    if (error is TimeoutException) {
      return 'timeout_error';
    }
    // Auth/permission errors (platform/channel level)
    if (error is PlatformException) {
      return 'auth_error';
    }
    // Auth/state errors (e.g., user not authenticated)
    if (error is StateError && error.message.contains('auth')) {
      return 'auth_state_error';
    }
    // Validation/format issues
    if (error is FormatException) {
      return 'validation_error';
    }
    // Fallback
    return 'unknown_error';
  }

  Future<void> _handleAccept() async {
    setState(() => _isLoading = true);
    // Keep version/scopes in outer scope so both success and failure paths
    // can include them in analytics.
    final version = ConsentConfig.currentVersion;
    final scopes = ConsentConfig.requiredScopeNames;
    try {
      final consentService = ref.read(consentServiceProvider);

      await consentService.accept(version: version, scopes: scopes)
        .timeout(const Duration(seconds: 10));

      // Fire analytics event only after successful server persistence
      final analytics = ref.read(analyticsProvider);
      analytics.track('consent_accepted', {
        'policy_version': version,
        'required_ok': true,
        'scopes_count': scopes.length,
        'scopes': scopes,
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consentSnackbarAccepted)),
        );
      }
    } catch (e) {
      // Track consent failure with error and context; still show user-facing
      // feedback via SnackBar if the widget is mounted.
      final analytics = ref.read(analyticsProvider);
      analytics.track('consent_failed', {
        'error_type': _categorizeError(e),
        'policy_version': version,
        'scopes_count': scopes.length,
        'scopes': scopes,
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.consentSnackbarError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAccept,
      child: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Accept Terms'),
    );
  }
}
