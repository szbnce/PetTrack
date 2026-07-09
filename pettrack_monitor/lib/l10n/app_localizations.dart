import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hu.dart';

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
    Locale('hu'),
  ];

  /// No description provided for @setupTitle.
  ///
  /// In en, this message translates to:
  /// **'PetTrack Monitor Setup'**
  String get setupTitle;

  /// No description provided for @setupNextStep.
  ///
  /// In en, this message translates to:
  /// **'Next step'**
  String get setupNextStep;

  /// No description provided for @setupAutostartWarning.
  ///
  /// In en, this message translates to:
  /// **'Before you start this, go out from the app, go into the app information and turn on Autostart for this to work!'**
  String get setupAutostartWarning;

  /// No description provided for @setupServerIp.
  ///
  /// In en, this message translates to:
  /// **'Backend server IP and Port'**
  String get setupServerIp;

  /// No description provided for @setupDeviceName.
  ///
  /// In en, this message translates to:
  /// **'Device Name (Monitor ID)'**
  String get setupDeviceName;

  /// No description provided for @setupSecurityToken.
  ///
  /// In en, this message translates to:
  /// **'Security Token'**
  String get setupSecurityToken;

  /// No description provided for @setupSaveAndStart.
  ///
  /// In en, this message translates to:
  /// **'Save & Start'**
  String get setupSaveAndStart;

  /// No description provided for @monitorTitle.
  ///
  /// In en, this message translates to:
  /// **'PetTrack Monitor'**
  String get monitorTitle;

  /// No description provided for @monitorSleepMode.
  ///
  /// In en, this message translates to:
  /// **'Sleep Mode (Dim Screen)'**
  String get monitorSleepMode;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDark;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @aboutTitle.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get aboutTitle;

  /// No description provided for @aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'This app securely streams your camera feed to the PetTrack backend.'**
  String get aboutDescription;

  /// No description provided for @monitorStreamingLive.
  ///
  /// In en, this message translates to:
  /// **'Streaming live video...'**
  String get monitorStreamingLive;

  /// No description provided for @monitorWaitingForStart.
  ///
  /// In en, this message translates to:
  /// **'Waiting for START command...'**
  String get monitorWaitingForStart;

  /// No description provided for @monitorReconnecting.
  ///
  /// In en, this message translates to:
  /// **'Reconnecting...'**
  String get monitorReconnecting;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @stop.
  ///
  /// In en, this message translates to:
  /// **'Stop'**
  String get stop;

  /// No description provided for @monitorServer.
  ///
  /// In en, this message translates to:
  /// **'Server:\n{ip}'**
  String monitorServer(String ip);

  /// No description provided for @monitorSleeping.
  ///
  /// In en, this message translates to:
  /// **'Sleeping... Double tap to wake'**
  String get monitorSleeping;

  /// No description provided for @errorConnectionFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to server! Check IP and Token.\nError: {error}'**
  String errorConnectionFailed(String error);

  /// No description provided for @languageTitle.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get languageTitle;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageHungarian.
  ///
  /// In en, this message translates to:
  /// **'Magyar'**
  String get languageHungarian;

  /// No description provided for @setupScanQrTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan the QR code from the PetTrack App'**
  String get setupScanQrTitle;
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
      <String>['en', 'hu'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hu':
      return AppLocalizationsHu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
