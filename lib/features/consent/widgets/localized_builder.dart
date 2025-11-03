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
    final fallbackLocale = supportedLocales.first;
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
            // Fail-fast in debug with clear remediation guidance.
            assert(() {
              throw FlutterError.fromParts(<DiagnosticsNode>[
                ErrorSummary('Missing AppLocalizations in LocalizedBuilder.'),
                ErrorDescription(
                  'AppLocalizations.of(context) returned null. This usually means the localization delegates are not configured on your app root.',
                ),
                ErrorHint(
                  'Add the following to your MaterialApp (or CupertinoApp):\n'
                  '  localizationsDelegates: AppLocalizations.localizationsDelegates,\n'
                  '  supportedLocales: AppLocalizations.supportedLocales,',
                ),
              ]);
            }());

            // Release: log and return a safe fallback to avoid a blank screen crash.
            log.e(
              'Failed to resolve AppLocalizations; returning safe fallback widget.',
              tag: 'localized_builder',
            );
            FlutterError.reportError(FlutterErrorDetails(
              exception: FlutterError('AppLocalizations.of(context) returned null'),
              library: 'localized_builder',
              context: ErrorDescription('Localizations.override resolution failed'),
            ));
            return const SizedBox.shrink();
          }
          return builder(overrideContext, resolved);
        },
      ),
    );
  }
}
