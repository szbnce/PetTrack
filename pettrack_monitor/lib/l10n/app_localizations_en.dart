// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get setupTitle => 'PetTrack Monitor Setup';

  @override
  String get setupNextStep => 'Next step';

  @override
  String get setupAutostartWarning =>
      'Before you start this, go out from the app, go into the app information and turn on Autostart for this to work!';

  @override
  String get setupServerIp => 'Backend server IP and Port';

  @override
  String get setupDeviceName => 'Device Name (Monitor ID)';

  @override
  String get setupSecurityToken => 'Security Token';

  @override
  String get setupSaveAndStart => 'Save & Start';

  @override
  String get monitorTitle => 'PetTrack Monitor';

  @override
  String get monitorSleepMode => 'Sleep Mode (Dim Screen)';

  @override
  String get themeLight => 'Light Mode';

  @override
  String get themeDark => 'Dark Mode';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get aboutTitle => 'About';

  @override
  String get aboutDescription =>
      'This app securely streams your camera feed to the PetTrack backend.';

  @override
  String get monitorStreamingLive => 'Streaming live video...';

  @override
  String get monitorWaitingForStart => 'Waiting for START command...';

  @override
  String get monitorReconnecting => 'Reconnecting...';

  @override
  String get start => 'Start';

  @override
  String get stop => 'Stop';

  @override
  String monitorServer(String ip) {
    return 'Server:\n$ip';
  }

  @override
  String get monitorSleeping => 'Sleeping... Double tap to wake';

  @override
  String errorConnectionFailed(String error) {
    return 'Failed to connect to server! Check IP and Token.\nError: $error';
  }

  @override
  String get languageTitle => 'Language';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get setupScanQrTitle => 'Scan the QR code from the PetTrack App';
}
