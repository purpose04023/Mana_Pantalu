import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_te.dart';

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
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('te')
  ];

  /// No description provided for @appTitle.
  ///
  /// In te, this message translates to:
  /// **'మన పంటలు'**
  String get appTitle;

  /// No description provided for @welcomeTitle.
  ///
  /// In te, this message translates to:
  /// **'మన పంటలకు స్వాగతం'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In te, this message translates to:
  /// **'మీ పంటల రక్షణ కోసం AI ఆధారిత వ్యవసాయ సహాయకుడు'**
  String get welcomeSubtitle;

  /// No description provided for @start.
  ///
  /// In te, this message translates to:
  /// **'ప్రారంభించండి'**
  String get start;

  /// No description provided for @home.
  ///
  /// In te, this message translates to:
  /// **'హోమ్'**
  String get home;

  /// No description provided for @diagnose.
  ///
  /// In te, this message translates to:
  /// **'పరీక్ష'**
  String get diagnose;

  /// No description provided for @myCrops.
  ///
  /// In te, this message translates to:
  /// **'నా పంటలు'**
  String get myCrops;

  /// No description provided for @tips.
  ///
  /// In te, this message translates to:
  /// **'సూచనలు'**
  String get tips;

  /// No description provided for @profile.
  ///
  /// In te, this message translates to:
  /// **'ప్రొఫైల్'**
  String get profile;

  /// No description provided for @weather.
  ///
  /// In te, this message translates to:
  /// **'వాతావరణం'**
  String get weather;

  /// No description provided for @help.
  ///
  /// In te, this message translates to:
  /// **'సహాయం'**
  String get help;

  /// No description provided for @greeting.
  ///
  /// In te, this message translates to:
  /// **'నమస్కారం!'**
  String get greeting;

  /// No description provided for @takePhoto.
  ///
  /// In te, this message translates to:
  /// **'కెమెరాతో ఫోటో తీయండి'**
  String get takePhoto;

  /// No description provided for @pickGallery.
  ///
  /// In te, this message translates to:
  /// **'గ్యాలరీ నుంచి ఎంచుకోండి'**
  String get pickGallery;

  /// No description provided for @scanning.
  ///
  /// In te, this message translates to:
  /// **'పంటను పరిశీలిస్తోంది…'**
  String get scanning;

  /// No description provided for @detectedCrop.
  ///
  /// In te, this message translates to:
  /// **'గుర్తించిన పంట'**
  String get detectedCrop;

  /// No description provided for @possibleIssue.
  ///
  /// In te, this message translates to:
  /// **'సాధ్యమైన సమస్య'**
  String get possibleIssue;

  /// No description provided for @notSure.
  ///
  /// In te, this message translates to:
  /// **'ఖచ్చితంగా చెప్పలేకపోతున్నాం'**
  String get notSure;

  /// No description provided for @retake.
  ///
  /// In te, this message translates to:
  /// **'మళ్ళీ ఫోటో తీయండి'**
  String get retake;

  /// No description provided for @askExpert.
  ///
  /// In te, this message translates to:
  /// **'నిపుణుడిని అడగండి'**
  String get askExpert;

  /// No description provided for @listen.
  ///
  /// In te, this message translates to:
  /// **'వినండి'**
  String get listen;

  /// No description provided for @stop.
  ///
  /// In te, this message translates to:
  /// **'ఆపండి'**
  String get stop;

  /// No description provided for @symptoms.
  ///
  /// In te, this message translates to:
  /// **'లక్షణాలు'**
  String get symptoms;

  /// No description provided for @causes.
  ///
  /// In te, this message translates to:
  /// **'కారణాలు'**
  String get causes;

  /// No description provided for @prevention.
  ///
  /// In te, this message translates to:
  /// **'నివారణ'**
  String get prevention;

  /// No description provided for @care.
  ///
  /// In te, this message translates to:
  /// **'జాగ్రత్తలు'**
  String get care;

  /// No description provided for @treatment.
  ///
  /// In te, this message translates to:
  /// **'చికిత్స'**
  String get treatment;

  /// No description provided for @save.
  ///
  /// In te, this message translates to:
  /// **'సేవ్ చేయండి'**
  String get save;

  /// No description provided for @scanAgain.
  ///
  /// In te, this message translates to:
  /// **'మళ్ళీ స్కాన్ చేయండి'**
  String get scanAgain;

  /// No description provided for @wasHelpful.
  ///
  /// In te, this message translates to:
  /// **'ఈ సమాచారం ఉపయోగపడిందా?'**
  String get wasHelpful;

  /// No description provided for @trustNote.
  ///
  /// In te, this message translates to:
  /// **'ఇది సూచన మాత్రమే. అనుమానం ఉంటే వ్యవసాయ అధికారిని సంప్రదించండి.'**
  String get trustNote;

  /// No description provided for @addCrop.
  ///
  /// In te, this message translates to:
  /// **'+ పంట జోడించండి'**
  String get addCrop;

  /// No description provided for @sowingDate.
  ///
  /// In te, this message translates to:
  /// **'విత్తనం నాటిన తేదీ'**
  String get sowingDate;

  /// No description provided for @fieldSize.
  ///
  /// In te, this message translates to:
  /// **'పొలం విస్తీర్ణం (ఎకరాలు)'**
  String get fieldSize;

  /// No description provided for @location.
  ///
  /// In te, this message translates to:
  /// **'ప్రాంతం / జిల్లా'**
  String get location;

  /// No description provided for @language.
  ///
  /// In te, this message translates to:
  /// **'భాష'**
  String get language;

  /// No description provided for @notifications.
  ///
  /// In te, this message translates to:
  /// **'నోటిఫికేషన్లు'**
  String get notifications;

  /// No description provided for @scanHistory.
  ///
  /// In te, this message translates to:
  /// **'గత పరీక్షల వివరాలు'**
  String get scanHistory;

  /// No description provided for @feedback.
  ///
  /// In te, this message translates to:
  /// **'అభిప్రాయం పంపండి'**
  String get feedback;

  /// No description provided for @signInPhone.
  ///
  /// In te, this message translates to:
  /// **'ఫోన్ నంబర్‌తో సైన్ ఇన్ చేయండి'**
  String get signInPhone;

  /// No description provided for @send.
  ///
  /// In te, this message translates to:
  /// **'పంపండి'**
  String get send;

  /// No description provided for @retry.
  ///
  /// In te, this message translates to:
  /// **'మళ్ళీ ప్రయత్నించండి'**
  String get retry;

  /// No description provided for @noInternet.
  ///
  /// In te, this message translates to:
  /// **'ఇంటర్నెట్ కనెక్షన్ లేదు'**
  String get noInternet;

  /// No description provided for @cancel.
  ///
  /// In te, this message translates to:
  /// **'రద్దు'**
  String get cancel;

  /// No description provided for @cropLibrary.
  ///
  /// In te, this message translates to:
  /// **'పంటల సమాచారం'**
  String get cropLibrary;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'te'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'te':
      return AppLocalizationsTe();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
