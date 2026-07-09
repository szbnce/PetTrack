// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get setupTitle => 'PetTrack Monitor Beállítás';

  @override
  String get setupNextStep => 'Következő lépés';

  @override
  String get setupAutostartWarning =>
      'Mielőtt továbbhaladsz, lépj ki az alkalmazásból, menj az app infókba, és engedélyezd az Automatikus indítast (Autostart)!';

  @override
  String get setupServerIp => 'Szerver IP címe és Port';

  @override
  String get setupDeviceName => 'Ezköz neve (Monitor ID)';

  @override
  String get setupSecurityToken => 'Biztonsági Token';

  @override
  String get setupSaveAndStart => 'Mentés és indítás';

  @override
  String get monitorTitle => 'PetTrack Monitor';

  @override
  String get monitorSleepMode => 'Alvó mód (Képernyő sötétítése)';

  @override
  String get themeLight => 'Világos mód';

  @override
  String get themeDark => 'Sötét mód';

  @override
  String get settingsTitle => 'Beállítások';

  @override
  String get aboutTitle => 'Névjegy';

  @override
  String get aboutDescription =>
      'Ez az alkalmazás közvetíti a kameraképet a PetTrack Serverre.';

  @override
  String get monitorStreamingLive => 'Élő közvetítés folyamatban...';

  @override
  String get monitorWaitingForStart => 'Várakozás a START parancsra...';

  @override
  String get monitorReconnecting => 'Újracsatlakozás...';

  @override
  String get start => 'Indítás';

  @override
  String get stop => 'Leállítás';

  @override
  String monitorServer(String ip) {
    return 'Szerver:\n$ip';
  }

  @override
  String get monitorSleeping => 'Alvó mód.... Dupla koppintás az ébresztéshez';

  @override
  String errorConnectionFailed(String error) {
    return 'Sikertelen csatlakozás a szerverhez! Ellenőrizd az IP-t és a Tokent.\nHiba: $error';
  }

  @override
  String get languageTitle => 'Nyelv';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageHungarian => 'Magyar';

  @override
  String get setupScanQrTitle => 'Olvasd be a QR kódot a PetTrack appból';

  @override
  String get lightMode => '☀️ Világos mód';

  @override
  String get darkMode => '🌙 Sötét mód';
}
