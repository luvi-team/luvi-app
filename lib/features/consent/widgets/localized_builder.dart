import 'package:flutter/widgets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/core/logging/logger.dart';

typedef LocalizedContentBuilder =
    Widget Function(BuildContext context, AppLocalizations localizations);

/// Wraps localized content with a defensive override when delegates are missing.
class LocalizedBuilder extends StatelessWidget {
  const LocalizedBuilder({super.key, required this.builder});

  final LocalizedContentBuilder builder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (l10n != null) {
      return builder(context, l10n);
    }

    final supportedLocales = AppLocalizations.supportedLocales;
    // Guard against empty supportedLocales to avoid RangeError on .first.
    final Locale fallbackLocale;
    if (supportedLocales.isEmpty) {
      // Fallback to a sensible default and log a warning for diagnostics.
      fallbackLocale = const Locale('en');
      log.w(
        'AppLocalizations.supportedLocales is empty. Falling back to en.',
        tag: 'localized_builder',
      );
    } else {
      fallbackLocale = supportedLocales.first;
    }
    final currentLocale = Localizations.maybeLocaleOf(context);
    final effectiveLocale = currentLocale == null
        ? fallbackLocale
        : supportedLocales.firstWhere(
            (supported) =>
                supported == currentLocale ||
                supported.languageCode == currentLocale.languageCode,
            orElse: () => fallbackLocale,
          );

    return Localizations.override(
      context: context,
      delegates: AppLocalizations.localizationsDelegates,
      locale: effectiveLocale,
      child: Builder(
        builder: (overrideContext) {
          final resolved = AppLocalizations.of(overrideContext);
          if (resolved == null) {
            // Debug: warn loudly but do not crash the app.
            assert(() {
              log.e(
                'AppLocalizations.of(context) returned null. Ensure delegates/supportedLocales are configured at app root.',
                tag: 'localized_builder',
              );
              return true;
            }());

            // Release: show a minimal error UI instead of a blank widget.
            FlutterError.reportError(FlutterErrorDetails(
              exception: FlutterError('AppLocalizations.of(context) returned null'),
              library: 'localized_builder',
              context: ErrorDescription('Localizations.override resolution failed'),
            ));
            return Semantics(
              label: 'Localization unavailable',
              child: const Center(
                child: Text(
                  'Localization unavailable',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return builder(overrideContext, resolved);
        },
      ),
    );
  }
}
