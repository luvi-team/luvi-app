import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/l10n/l10n_capabilities.dart';

/// Provides localized auth strings while keeping the existing static API surface
/// for legacy callers. Strings resolve against [AppLocalizations] and can be
/// overridden in tests via [debugOverrideLocalizations].
class AuthStrings {
  AuthStrings._();

  static AppLocalizations? _debugOverride;
  static ui.Locale? Function()? _resolver;
  // Cache is accessed only on Flutter's main isolate. This class assumes
  // single-threaded access from the UI thread; no explicit locking is used.
  // Cache is invalidated on locale change by the app root (see MyAppWrapper
  // builder/LocaleChangeCacheReset in main.dart) or via debugResetCache().
  static AppLocalizations? _cachedL10n;
  static String? _cachedTag;

  @visibleForTesting
  static void debugOverrideLocalizations(AppLocalizations? override) {
    _debugOverride = override;
  }

  @visibleForTesting
  static void overrideResolver(ui.Locale? Function()? resolver) {
    _resolver = resolver;
  }

  @visibleForTesting
  static void debugResetCache() {
    // Delegate to the public API to ensure consistent behavior in tests.
    resetCache();
  }

  /// Public API to clear the cached localization instance.
  ///
  /// Use this in production code when locale changes (e.g., after
  /// Localizations updates) to ensure freshly resolved strings.
  static void resetCache() {
    _cachedL10n = null;
    _cachedTag = null;
  }

  static AppLocalizations _l10n() {
    if (_debugOverride != null) {
      return _debugOverride!;
    }

    final resolvedLocale =
        _resolver?.call() ?? ui.PlatformDispatcher.instance.locale;
    final currentTag = resolvedLocale.toLanguageTag();
    final cached = _cachedL10n;
    if (cached != null && _cachedTag == currentTag) {
      return cached;
    }
    const fallbackLocale = ui.Locale.fromSubtags(languageCode: 'en');

    for (final candidate in <ui.Locale>[
      resolvedLocale,
      ui.Locale.fromSubtags(languageCode: resolvedLocale.languageCode),
      fallbackLocale,
    ]) {
      try {
        final l10n = lookupAppLocalizations(candidate);
        _cachedL10n = l10n;
        _cachedTag = candidate.toLanguageTag();
        return l10n;
      } on FlutterError {
        continue;
      }
    }

    // Fallback was already attempted in the loop above; if we reach here, rethrow
    throw FlutterError('AppLocalizations lookup failed for all candidates including fallback.');
  }

  static String get loginHeadline => _l10n().authLoginHeadline;
  static String get loginSubhead => _l10n().authLoginSubhead;
  static String get loginCta => _l10n().authLoginCta;
  static String get loginCtaButton => loginCta;
  static String get loginCtaLinkPrefix => _l10n().authLoginCtaLinkPrefix;
  static String get loginCtaLinkAction => _l10n().authLoginCtaLinkAction;
  static String get loginCtaLoadingSemantic =>
      _l10n().authLoginCtaLoadingSemantic;
  static String get loginForgot => _l10n().authLoginForgot;
  static String get loginSocialDivider => _l10n().authLoginSocialDivider;
  static String get loginSocialGoogle => _l10n().authLoginSocialGoogle;
  static String get errEmailInvalid => _l10n().authErrEmailInvalid;
  static String get errEmailEmpty => _l10n().authErrEmailEmpty;
  static String get errPasswordInvalid => _l10n().authErrPasswordInvalid;
  static String get errPasswordEmpty => _l10n().authErrPasswordEmpty;
  // More granular password validation errors with graceful fallback to the
  // generic password error when the specific localization is not available yet.
  static String get errPasswordTooShort {
    final l = _l10n();
    return l.hasGranularPasswordErrors
        ? l.authErrPasswordTooShort
        : l.authErrPasswordInvalid;
  }
  static String get errPasswordMissingTypes {
    final l = _l10n();
    return l.hasGranularPasswordErrors
        ? l.authErrPasswordMissingTypes
        : l.authErrPasswordInvalid;
  }
  static String get errPasswordCommonWeak {
    final l = _l10n();
    return l.hasGranularPasswordErrors
        ? l.authErrPasswordCommonWeak
        : l.authErrPasswordInvalid;
  }
  static String get errConfirmEmail => _l10n().authErrConfirmEmail;
  static String get invalidCredentials => _l10n().authInvalidCredentials;
  static String get errLoginUnavailable => _l10n().authErrLoginUnavailable;
  static String get passwordMismatchError => _l10n().authPasswordMismatchError;
  static String get passwordUpdateError => _l10n().authPasswordUpdateError;
  static String get emailHint => _l10n().authEmailHint;
  static String get passwordHint => _l10n().authPasswordHint;
  static String get signupTitle => _l10n().authSignupTitle;
  static String get signupSubtitle => _l10n().authSignupSubtitle;
  static String get signupCta => _l10n().authSignupCta;
  static String get signupCtaLoadingSemantic =>
      _l10n().authSignupCtaLoadingSemantic;
  static String get signupLinkPrefix => _l10n().authSignupLinkPrefix;
  static String get signupLinkAction => _l10n().authSignupLinkAction;
  static String get signupHintFirstName => _l10n().authSignupHintFirstName;
  static String get signupHintLastName => _l10n().authSignupHintLastName;
  static String get signupHintPhone => _l10n().authSignupHintPhone;
  static String get signupMissingFields => _l10n().authSignupMissingFields;
  static String get signupGenericError => _l10n().authSignupGenericError;
  static String get forgotTitle => _l10n().authForgotTitle;
  static String get forgotSubtitle => _l10n().authForgotSubtitle;
  static String get forgotCta => _l10n().authForgotCta;
  static String get backSemantic => _l10n().authBackSemantic;
  static String get successPwdTitle => _l10n().authSuccessPwdTitle;
  static String get successPwdSubtitle => _l10n().authSuccessPwdSubtitle;
  static String get successForgotTitle => _l10n().authSuccessForgotTitle;
  static String get successForgotSubtitle => _l10n().authSuccessForgotSubtitle;
  static String get successCta => _l10n().authSuccessCta;
  static String get createNewHint1 => _l10n().authCreateNewHint1;
  static String get createNewHint2 => _l10n().authCreateNewHint2;
  static String get createNewCta => _l10n().authCreateNewCta;
  static String get createNewTitle => _l10n().authCreateNewTitle;
  static String get createNewSubtitle => _l10n().authCreateNewSubtitle;
  static String get verifyResetTitle => _l10n().authVerifyResetTitle;
  static String get verifyResetSubtitle => _l10n().authVerifyResetSubtitle;
  static String get verifyEmailTitle => _l10n().authVerifyEmailTitle;
  static String get verifyEmailSubtitle => _l10n().authVerifyEmailSubtitle;
  static String get verifyCta => _l10n().authVerifyCta;
  static String get verifyHelper => _l10n().authVerifyHelper;
  static String get verifyResend => _l10n().authVerifyResend;
}
