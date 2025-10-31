import 'package:flutter/widgets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';

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
            return const SizedBox.shrink();
          }
          return builder(overrideContext, resolved);
        },
      ),
    );
  }
}
