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
}
