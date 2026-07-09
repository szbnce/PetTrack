// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'PetTrack';

  @override
  String get settingsTitle => 'System Settings';

  @override
  String get uploadProfilePicture => 'Upload profile picture';

  @override
  String get serverIp => 'Server IP';

  @override
  String get serverIpHint => 'e.g. 192.168.1.100';

  @override
  String get secretToken => 'Secret Token';

  @override
  String get petName => 'Pet name';

  @override
  String get petNameHint => 'Enter the name';

  @override
  String get save => 'Save';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navZones => 'Zones';

  @override
  String get navSettings => 'Settings';

  @override
  String get greeting => 'Hi Boss!';

  @override
  String greetingSubtitle(String petName) {
    return 'Here is $petName\'s day today.';
  }

  @override
  String get liveVideo => 'Live Video';

  @override
  String lastMovement(String time) {
    return 'Last movement: $time';
  }

  @override
  String get distance => 'Distance';

  @override
  String get feedings => 'Feedings';

  @override
  String get activities => 'Activities';

  @override
  String get noRecentEvents => 'No recent events';

  @override
  String zoneEntered(String petName, String zone) {
    return '$petName entered $zone';
  }

  @override
  String zoneLeft(String petName, String zone) {
    return '$petName left $zone';
  }

  @override
  String get cameraDetectedMovement => 'Camera detected movement.';

  @override
  String get editZones => 'Edit Zones';

  @override
  String get addNewZone => 'Add new zone';

  @override
  String get cancel => 'Cancel';

  @override
  String get existingZones => 'Existing zones';

  @override
  String get safeZone => 'Safe zone';

  @override
  String get warningZone => 'Warning zone';

  @override
  String get alertZone => 'Alert zone';

  @override
  String get today => 'Today';

  @override
  String get language => 'Language';

  @override
  String get active => 'Active';

  @override
  String get mainMonitor => 'Main Monitor';

  @override
  String get favoriteZone => 'Favorite zone';

  @override
  String get lastSeen => 'Last seen';

  @override
  String get justNow => 'Just now';

  @override
  String minsAgo(int mins) {
    return '$mins mins ago';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours hours ago';
  }

  @override
  String daysAgo(int days) {
    return '$days days ago';
  }

  @override
  String get unknown => 'Unknown';

  @override
  String get leftTheZone => 'Left the zone.';

  @override
  String get greetingsList =>
      'Hi Boss!|Welcome back!|Have a nice day!|Hey!|How are you?|Hello!|What\'s up?|Good to see you again!|Ready?|Let\'s see what they are doing!';

  @override
  String get subGreetingsList =>
      'Everything is fine here.|Seems to be sleeping.|Full of energy!|Watching the area.|Waiting for dinner.|Sniffing something.|Resting peacefully.|At the favorite spot.|Wants to play.|Everything is quiet.';

  @override
  String get petTypeTitle => 'Pet Type';

  @override
  String get petTypeDog => 'Dog';

  @override
  String get petTypeCat => 'Cat';

  @override
  String get petTypeRabbit => 'Rabbit';

  @override
  String get petTypeGuineaPig => 'Guinea Pig';

  @override
  String get petTypeBird => 'Bird';

  @override
  String get petTypeOther => 'Other';

  @override
  String get alertsTitle => 'Notifications';

  @override
  String get alertsZone => 'Zone alerts (Enter/Exit)';

  @override
  String get alertsBattery => 'Low battery alert';

  @override
  String batteryThreshold(int level) {
    return 'Battery threshold: $level%';
  }

  @override
  String get testNotification => 'Test Notification';

  @override
  String get testNotifTitle => 'Test Notification';

  @override
  String get testNotifBody => 'You have successfully set up notifications!';

  @override
  String get batteryLowTitle => 'Battery Low!';

  @override
  String batteryLowBody(int level) {
    return 'The pet tracker battery is below $level%.';
  }

  @override
  String get cameraOffline => 'Camera Offline';

  @override
  String secondsAgo(int seconds) {
    return '$seconds seconds ago';
  }

  @override
  String get toiletZone => 'Litter Box / Toilet';

  @override
  String get bedZone => 'Bed / Resting Area';

  @override
  String get waterZone => 'Water Bowl';

  @override
  String get foodZone => 'Food Bowl';

  @override
  String get playZone => 'Play Area';

  @override
  String get appearance => 'Appearance (Theme)';

  @override
  String get themeSystem => 'System default';

  @override
  String get themeLight => 'Light';

  @override
  String get themeDark => 'Dark';

  @override
  String failedToLoadPetProfile(String e) {
    return 'Failed to load Pet Profile $e';
  }

  @override
  String get invalidSecretToken => 'Invalid Secret Token!';

  @override
  String get serverUnreachable => 'Server Unreachable!';

  @override
  String decodingErrorZones(String e) {
    return 'Decoding error at zones: $e';
  }

  @override
  String decodingError(String e) {
    return 'Decoding error: $e';
  }

  @override
  String profileUploadError(String e) {
    return 'Profile upload error: $e';
  }

  @override
  String get setupWelcomeTitle => 'Welcome to PetTrack!';

  @override
  String get setupWelcomeDesc =>
      'The best way to keep track of your pet.\n\nFirst, let\'s connect to the server.';

  @override
  String get setupScanBtn => 'Read QR Code';

  @override
  String get setupSuccessTitle => 'Success!';

  @override
  String get setupSuccessDesc =>
      'The connection is encrypted.\nNow let\'s register your pet.';

  @override
  String get setupNextBtn => 'Next Step';

  @override
  String get setupPinTitle => 'Setup a Web PIN';

  @override
  String get setupPinDesc =>
      'Create a 4-digit PIN to securely login from your browser.';

  @override
  String get setupFinishBtn => 'Finish and Start';

  @override
  String get setupErrConnect =>
      'Failed to connect to the server! Check the network.';

  @override
  String get setupErrSave => 'Failed to save profile.';

  @override
  String get setupErrEmpty => 'Please enter a name and a 4-digit PIN!';

  @override
  String get setupMonitorTitle => 'Monitor Setup';

  @override
  String get setupMonitorDesc =>
      'Open the Monitor app on the other phone and scan this QR code to connect!';

  @override
  String get settingsShowQrBtn => 'Show QR Code';

  @override
  String get settingsQrDialogDesc => 'Scan with the old phone:';

  @override
  String get settingsQrDialogDone => 'Done';

  @override
  String get settingsResetApp => 'Reset App & Restart Setup';

  @override
  String get settingsResetConfirmTitle => 'Are you sure?';

  @override
  String get settingsResetConfirmDesc =>
      'This will delete all saved data and restart the setup wizard.';

  @override
  String get serverUnreachableTitle => 'Server Unreachable';

  @override
  String get serverUnreachableDesc =>
      'Cannot connect to the PetTrack server.\nPlease check your network or if the server is running.';

  @override
  String get profileAndSystem => 'Profile & System';

  @override
  String get monitorAndConnection => 'Monitor & Connection';

  @override
  String get offlineStatus => 'OFFLINE!';

  @override
  String get liveStatus => 'Live';

  @override
  String get searchingStatus => 'Searching...';
}
