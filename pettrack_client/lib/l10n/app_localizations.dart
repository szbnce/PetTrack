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

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'PetTrack'**
  String get appName;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get settingsTitle;

  /// No description provided for @uploadProfilePicture.
  ///
  /// In en, this message translates to:
  /// **'Upload profile picture'**
  String get uploadProfilePicture;

  /// No description provided for @serverIp.
  ///
  /// In en, this message translates to:
  /// **'Server IP'**
  String get serverIp;

  /// No description provided for @serverIpHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.100'**
  String get serverIpHint;

  /// No description provided for @secretToken.
  ///
  /// In en, this message translates to:
  /// **'Secret Token'**
  String get secretToken;

  /// No description provided for @petName.
  ///
  /// In en, this message translates to:
  /// **'Pet name'**
  String get petName;

  /// No description provided for @petNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter the name'**
  String get petNameHint;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @navDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get navDashboard;

  /// No description provided for @navZones.
  ///
  /// In en, this message translates to:
  /// **'Zones'**
  String get navZones;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @greeting.
  ///
  /// In en, this message translates to:
  /// **'Hi Boss!'**
  String get greeting;

  /// No description provided for @greetingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Here is {petName}\'s day today.'**
  String greetingSubtitle(String petName);

  /// No description provided for @liveVideo.
  ///
  /// In en, this message translates to:
  /// **'Live Video'**
  String get liveVideo;

  /// No description provided for @lastMovement.
  ///
  /// In en, this message translates to:
  /// **'Last movement: {time}'**
  String lastMovement(String time);

  /// No description provided for @distance.
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// No description provided for @feedings.
  ///
  /// In en, this message translates to:
  /// **'Feedings'**
  String get feedings;

  /// No description provided for @activities.
  ///
  /// In en, this message translates to:
  /// **'Activities'**
  String get activities;

  /// No description provided for @noRecentEvents.
  ///
  /// In en, this message translates to:
  /// **'No recent events'**
  String get noRecentEvents;

  /// No description provided for @zoneEntered.
  ///
  /// In en, this message translates to:
  /// **'{petName} entered {zone}'**
  String zoneEntered(String petName, String zone);

  /// No description provided for @zoneLeft.
  ///
  /// In en, this message translates to:
  /// **'{petName} left {zone}'**
  String zoneLeft(String petName, String zone);

  /// No description provided for @cameraDetectedMovement.
  ///
  /// In en, this message translates to:
  /// **'Camera detected movement.'**
  String get cameraDetectedMovement;

  /// No description provided for @editZones.
  ///
  /// In en, this message translates to:
  /// **'Edit Zones'**
  String get editZones;

  /// No description provided for @addNewZone.
  ///
  /// In en, this message translates to:
  /// **'Add new zone'**
  String get addNewZone;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @existingZones.
  ///
  /// In en, this message translates to:
  /// **'Existing zones'**
  String get existingZones;

  /// No description provided for @safeZone.
  ///
  /// In en, this message translates to:
  /// **'Safe zone'**
  String get safeZone;

  /// No description provided for @warningZone.
  ///
  /// In en, this message translates to:
  /// **'Warning zone'**
  String get warningZone;

  /// No description provided for @alertZone.
  ///
  /// In en, this message translates to:
  /// **'Alert zone'**
  String get alertZone;

  /// No description provided for @today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @mainMonitor.
  ///
  /// In en, this message translates to:
  /// **'Main Monitor'**
  String get mainMonitor;

  /// No description provided for @favoriteZone.
  ///
  /// In en, this message translates to:
  /// **'Favorite zone'**
  String get favoriteZone;

  /// No description provided for @lastSeen.
  ///
  /// In en, this message translates to:
  /// **'Last seen'**
  String get lastSeen;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minsAgo.
  ///
  /// In en, this message translates to:
  /// **'{mins} mins ago'**
  String minsAgo(int mins);

  /// No description provided for @hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours ago'**
  String hoursAgo(int hours);

  /// No description provided for @daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{days} days ago'**
  String daysAgo(int days);

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @leftTheZone.
  ///
  /// In en, this message translates to:
  /// **'Left the zone.'**
  String get leftTheZone;

  /// No description provided for @greetingsList.
  ///
  /// In en, this message translates to:
  /// **'Hi Boss!|Welcome back!|Have a nice day!|Hey!|How are you?|Hello!|What\'s up?|Good to see you again!|Ready?|Let\'s see what they are doing!'**
  String get greetingsList;

  /// No description provided for @subGreetingsList.
  ///
  /// In en, this message translates to:
  /// **'Everything is fine here.|Seems to be sleeping.|Full of energy!|Watching the area.|Waiting for dinner.|Sniffing something.|Resting peacefully.|At the favorite spot.|Wants to play.|Everything is quiet.'**
  String get subGreetingsList;

  /// No description provided for @petTypeTitle.
  ///
  /// In en, this message translates to:
  /// **'Pet Type'**
  String get petTypeTitle;

  /// No description provided for @petTypeDog.
  ///
  /// In en, this message translates to:
  /// **'Dog'**
  String get petTypeDog;

  /// No description provided for @petTypeCat.
  ///
  /// In en, this message translates to:
  /// **'Cat'**
  String get petTypeCat;

  /// No description provided for @petTypeRabbit.
  ///
  /// In en, this message translates to:
  /// **'Rabbit'**
  String get petTypeRabbit;

  /// No description provided for @petTypeGuineaPig.
  ///
  /// In en, this message translates to:
  /// **'Guinea Pig'**
  String get petTypeGuineaPig;

  /// No description provided for @petTypeBird.
  ///
  /// In en, this message translates to:
  /// **'Bird'**
  String get petTypeBird;

  /// No description provided for @petTypeOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get petTypeOther;

  /// No description provided for @alertsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get alertsTitle;

  /// No description provided for @alertsZone.
  ///
  /// In en, this message translates to:
  /// **'Zone alerts (Enter/Exit)'**
  String get alertsZone;

  /// No description provided for @alertsBattery.
  ///
  /// In en, this message translates to:
  /// **'Low battery alert'**
  String get alertsBattery;

  /// No description provided for @batteryThreshold.
  ///
  /// In en, this message translates to:
  /// **'Battery threshold: {level}%'**
  String batteryThreshold(int level);

  /// No description provided for @testNotification.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotification;

  /// No description provided for @testNotifTitle.
  ///
  /// In en, this message translates to:
  /// **'Test Notification'**
  String get testNotifTitle;

  /// No description provided for @testNotifBody.
  ///
  /// In en, this message translates to:
  /// **'You have successfully set up notifications!'**
  String get testNotifBody;

  /// No description provided for @batteryLowTitle.
  ///
  /// In en, this message translates to:
  /// **'Battery Low!'**
  String get batteryLowTitle;

  /// No description provided for @batteryLowBody.
  ///
  /// In en, this message translates to:
  /// **'The pet tracker battery is below {level}%.'**
  String batteryLowBody(int level);

  /// No description provided for @cameraOffline.
  ///
  /// In en, this message translates to:
  /// **'Camera Offline'**
  String get cameraOffline;

  /// No description provided for @secondsAgo.
  ///
  /// In en, this message translates to:
  /// **'{seconds} seconds ago'**
  String secondsAgo(int seconds);

  /// No description provided for @toiletZone.
  ///
  /// In en, this message translates to:
  /// **'Litter Box / Toilet'**
  String get toiletZone;

  /// No description provided for @bedZone.
  ///
  /// In en, this message translates to:
  /// **'Bed / Resting Area'**
  String get bedZone;

  /// No description provided for @waterZone.
  ///
  /// In en, this message translates to:
  /// **'Water Bowl'**
  String get waterZone;

  /// No description provided for @foodZone.
  ///
  /// In en, this message translates to:
  /// **'Food Bowl'**
  String get foodZone;

  /// No description provided for @playZone.
  ///
  /// In en, this message translates to:
  /// **'Play Area'**
  String get playZone;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance (Theme)'**
  String get appearance;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System default'**
  String get themeSystem;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @failedToLoadPetProfile.
  ///
  /// In en, this message translates to:
  /// **'Failed to load Pet Profile {e}'**
  String failedToLoadPetProfile(String e);

  /// No description provided for @invalidSecretToken.
  ///
  /// In en, this message translates to:
  /// **'Invalid Secret Token!'**
  String get invalidSecretToken;

  /// No description provided for @serverUnreachable.
  ///
  /// In en, this message translates to:
  /// **'Server Unreachable!'**
  String get serverUnreachable;

  /// No description provided for @decodingErrorZones.
  ///
  /// In en, this message translates to:
  /// **'Decoding error at zones: {e}'**
  String decodingErrorZones(String e);

  /// No description provided for @decodingError.
  ///
  /// In en, this message translates to:
  /// **'Decoding error: {e}'**
  String decodingError(String e);

  /// No description provided for @profileUploadError.
  ///
  /// In en, this message translates to:
  /// **'Profile upload error: {e}'**
  String profileUploadError(String e);

  /// No description provided for @setupWelcomeTitle.
  ///
  /// In en, this message translates to:
  /// **'Welcome to PetTrack!'**
  String get setupWelcomeTitle;

  /// No description provided for @setupWelcomeDesc.
  ///
  /// In en, this message translates to:
  /// **'The best way to keep track of your pet.\n\nFirst, let\'s connect to the server.'**
  String get setupWelcomeDesc;

  /// No description provided for @setupScanBtn.
  ///
  /// In en, this message translates to:
  /// **'Read QR Code'**
  String get setupScanBtn;

  /// No description provided for @setupSuccessTitle.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get setupSuccessTitle;

  /// No description provided for @setupSuccessDesc.
  ///
  /// In en, this message translates to:
  /// **'The connection is encrypted.\nNow let\'s register your pet.'**
  String get setupSuccessDesc;

  /// No description provided for @setupNextBtn.
  ///
  /// In en, this message translates to:
  /// **'Next Step'**
  String get setupNextBtn;

  /// No description provided for @setupPinTitle.
  ///
  /// In en, this message translates to:
  /// **'Setup a Web PIN'**
  String get setupPinTitle;

  /// No description provided for @setupPinDesc.
  ///
  /// In en, this message translates to:
  /// **'Create a 4-digit PIN to securely login from your browser.'**
  String get setupPinDesc;

  /// No description provided for @setupFinishBtn.
  ///
  /// In en, this message translates to:
  /// **'Finish and Start'**
  String get setupFinishBtn;

  /// No description provided for @setupErrConnect.
  ///
  /// In en, this message translates to:
  /// **'Failed to connect to the server! Check the network.'**
  String get setupErrConnect;

  /// No description provided for @setupErrSave.
  ///
  /// In en, this message translates to:
  /// **'Failed to save profile.'**
  String get setupErrSave;

  /// No description provided for @setupErrEmpty.
  ///
  /// In en, this message translates to:
  /// **'Please enter a name and a 4-digit PIN!'**
  String get setupErrEmpty;

  /// No description provided for @setupMonitorTitle.
  ///
  /// In en, this message translates to:
  /// **'Monitor Setup'**
  String get setupMonitorTitle;

  /// No description provided for @setupMonitorDesc.
  ///
  /// In en, this message translates to:
  /// **'Open the Monitor app on the other phone and scan this QR code to connect!'**
  String get setupMonitorDesc;

  /// No description provided for @settingsShowQrBtn.
  ///
  /// In en, this message translates to:
  /// **'Show QR Code'**
  String get settingsShowQrBtn;

  /// No description provided for @settingsQrDialogDesc.
  ///
  /// In en, this message translates to:
  /// **'Scan with the old phone:'**
  String get settingsQrDialogDesc;

  /// No description provided for @settingsQrDialogDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get settingsQrDialogDone;

  /// No description provided for @settingsResetApp.
  ///
  /// In en, this message translates to:
  /// **'Reset App & Restart Setup'**
  String get settingsResetApp;

  /// No description provided for @settingsResetConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get settingsResetConfirmTitle;

  /// No description provided for @settingsResetConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'This will delete all saved data and restart the setup wizard.'**
  String get settingsResetConfirmDesc;

  /// No description provided for @serverUnreachableTitle.
  ///
  /// In en, this message translates to:
  /// **'Server Unreachable'**
  String get serverUnreachableTitle;

  /// No description provided for @serverUnreachableDesc.
  ///
  /// In en, this message translates to:
  /// **'Cannot connect to the PetTrack server.\nPlease check your network or if the server is running.'**
  String get serverUnreachableDesc;

  /// No description provided for @profileAndSystem.
  ///
  /// In en, this message translates to:
  /// **'Profile & System'**
  String get profileAndSystem;

  /// No description provided for @monitorAndConnection.
  ///
  /// In en, this message translates to:
  /// **'Monitor & Connection'**
  String get monitorAndConnection;

  /// No description provided for @offlineStatus.
  ///
  /// In en, this message translates to:
  /// **'OFFLINE!'**
  String get offlineStatus;

  /// No description provided for @liveStatus.
  ///
  /// In en, this message translates to:
  /// **'Live'**
  String get liveStatus;

  /// No description provided for @searchingStatus.
  ///
  /// In en, this message translates to:
  /// **'Searching...'**
  String get searchingStatus;
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
