import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en')
  ];

  /// Header title for onboarding step 1.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself 💜'**
  String get onboarding01Title;

  /// Header title for onboarding step 2 (birthday).
  ///
  /// In en, this message translates to:
  /// **'When is your\nbirthday?'**
  String get onboarding02Title;

  /// No description provided for @onboarding04Title.
  ///
  /// In en, this message translates to:
  /// **'When did your last period start?'**
  String get onboarding04Title;

  /// Semantics label announcing the currently selected date on onboarding step 4.
  ///
  /// In en, this message translates to:
  /// **'Selected date: {date}'**
  String selectedDateLabel(String date);

  /// Accessibility announcement for the onboarding 04 callout info box.
  ///
  /// In en, this message translates to:
  /// **'Note: Don\'t worry if you don\'t remember the exact day. A rough estimate is enough to get started.'**
  String get onboarding04CalloutSemantics;

  /// Prefix text displayed before the emphasized part of the onboarding 04 callout.
  ///
  /// In en, this message translates to:
  /// **'Don\'t worry if you don\'t remember the '**
  String get onboarding04CalloutPrefix;

  /// Emphasized substring within the onboarding 04 callout text.
  ///
  /// In en, this message translates to:
  /// **'exact day'**
  String get onboarding04CalloutHighlight;

  /// Suffix text displayed after the emphasized part of the onboarding 04 callout.
  ///
  /// In en, this message translates to:
  /// **'. A rough estimate is enough to get started.'**
  String get onboarding04CalloutSuffix;

  /// Label for primary continue CTA buttons.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get commonContinue;

  /// Cycle length option describing short cycles.
  ///
  /// In en, this message translates to:
  /// **'Short (every 21-23 days)'**
  String get cycleLengthShort;

  /// Cycle length option describing slightly shorter cycles.
  ///
  /// In en, this message translates to:
  /// **'A bit shorter (every 24-26 days)'**
  String get cycleLengthLonger;

  /// Cycle length option describing standard cycles.
  ///
  /// In en, this message translates to:
  /// **'Standard (every 27-30 days)'**
  String get cycleLengthStandard;

  /// Cycle length option describing longer cycles.
  ///
  /// In en, this message translates to:
  /// **'Longer (every 31-35 days)'**
  String get cycleLengthLong;

  /// Cycle length option describing very long cycles.
  ///
  /// In en, this message translates to:
  /// **'Very long (36+ days)'**
  String get cycleLengthVeryLong;

  /// Header title for onboarding step 6.
  ///
  /// In en, this message translates to:
  /// **'Tell me about yourself 💜'**
  String get onboarding06Title;

  /// Question text for onboarding step 6 (cycle length).
  ///
  /// In en, this message translates to:
  /// **'How long does your cycle normally last?'**
  String get onboarding06Question;

  /// Supporting callout text shown below the cycle length options on step 6.
  ///
  /// In en, this message translates to:
  /// **'Every cycle is unique - just like you!'**
  String get onboarding06Callout;

  /// Header title for onboarding step 5 (period duration).
  ///
  /// In en, this message translates to:
  /// **'How long does your\nperiod usually last?'**
  String get onboarding05Title;

  /// Callout copy explaining why period duration is needed on step 5.
  ///
  /// In en, this message translates to:
  /// **'We need this starting point to calculate your current cycle phase. I learn with you and automatically adjust the predictions as soon as you log your next period.'**
  String get onboarding05Callout;

  /// Header title for onboarding step 7 (cycle regularity).
  ///
  /// In en, this message translates to:
  /// **'What is your cycle like?'**
  String get onboarding07Title;

  /// Option label for regular cycles on step 7.
  ///
  /// In en, this message translates to:
  /// **'Pretty regular'**
  String get onboarding07OptRegular;

  /// Option label for unpredictable cycles on step 7.
  ///
  /// In en, this message translates to:
  /// **'Mostly unpredictable'**
  String get onboarding07OptUnpredictable;

  /// Option label when the user is unsure about their cycle regularity on step 7.
  ///
  /// In en, this message translates to:
  /// **'Not sure'**
  String get onboarding07OptUnknown;

  /// Completion message shown on the onboarding done route.
  ///
  /// In en, this message translates to:
  /// **'Onboarding complete'**
  String get onboardingComplete;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['de', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
