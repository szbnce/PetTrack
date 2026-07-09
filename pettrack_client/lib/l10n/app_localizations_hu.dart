// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hungarian (`hu`).
class AppLocalizationsHu extends AppLocalizations {
  AppLocalizationsHu([String locale = 'hu']) : super(locale);

  @override
  String get appName => 'PetTrack';

  @override
  String get settingsTitle => 'Rendszer Beállítások';

  @override
  String get uploadProfilePicture => 'Profilkép feltöltése';

  @override
  String get serverIp => 'Szerver IP';

  @override
  String get serverIpHint => 'pl. 192.168.1.100';

  @override
  String get secretToken => 'Titkos Token';

  @override
  String get petName => 'Kedvenc neve';

  @override
  String get petNameHint => 'Írd be a nevét';

  @override
  String get save => 'Mentés';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get navZones => 'Zónák';

  @override
  String get navSettings => 'Beállítások';

  @override
  String get greeting => 'Szia Gazda!';

  @override
  String greetingSubtitle(String petName) {
    return 'Íme $petName mai napja.';
  }

  @override
  String get liveVideo => 'Élő Videó';

  @override
  String lastMovement(String time) {
    return 'Utolsó mozgás: $time';
  }

  @override
  String get distance => 'Távolság';

  @override
  String get feedings => 'Etetés';

  @override
  String get activities => 'Tevékenységek';

  @override
  String get noRecentEvents => 'Nincs friss esemény';

  @override
  String zoneEntered(String petName, String zone) {
    return '$petName belépett a(z) $zone területre';
  }

  @override
  String zoneLeft(String petName, String zone) {
    return '$petName kilépett a(z) $zone területről';
  }

  @override
  String get cameraDetectedMovement => 'Kamera érzékelte a mozgást.';

  @override
  String get editZones => 'Zónák Szerkesztése';

  @override
  String get addNewZone => 'Új zóna hozzáadása';

  @override
  String get cancel => 'Mégse';

  @override
  String get existingZones => 'Meglévő zónák';

  @override
  String get safeZone => 'Biztonságos zóna';

  @override
  String get warningZone => 'Figyelmeztető zóna';

  @override
  String get alertZone => 'Riasztási zóna';

  @override
  String get today => 'Ma';

  @override
  String get language => 'Nyelv';

  @override
  String get active => 'Aktív';

  @override
  String get mainMonitor => 'Fő Monitor';

  @override
  String get favoriteZone => 'Kedvenc zóna';

  @override
  String get lastSeen => 'Utolsó észlelés';

  @override
  String get justNow => 'Épp most';

  @override
  String minsAgo(int mins) {
    return '$mins perce';
  }

  @override
  String hoursAgo(int hours) {
    return '$hours órája';
  }

  @override
  String daysAgo(int days) {
    return '$days napja';
  }

  @override
  String get unknown => 'Ismeretlen';

  @override
  String get leftTheZone => 'Elhagyta a zónát.';

  @override
  String get greetingsList =>
      'Szia Gazda!|Üdv újra!|Szép napot!|Hali!|Hogy s mint?|Helló!|Mizu?|Jó újra látni!|Készen állsz?|Nézzük, mit csinál!';

  @override
  String get subGreetingsList =>
      'Itt minden rendben.|Úgy tűnik, alszik.|Tele van energiával!|Figyeli a terepet.|Várja a vacsorát.|Szimatol valamit.|Békésen pihen.|A kedvenc helyén van.|Játszani szeretne.|Minden csendes.';

  @override
  String get petTypeTitle => 'Állat fajtája';

  @override
  String get petTypeDog => 'Kutya';

  @override
  String get petTypeCat => 'Macska';

  @override
  String get petTypeRabbit => 'Nyúl';

  @override
  String get petTypeGuineaPig => 'Tengerimalac';

  @override
  String get petTypeBird => 'Madár';

  @override
  String get petTypeOther => 'Egyéb';

  @override
  String get alertsTitle => 'Értesítések';

  @override
  String get alertsZone => 'Zóna riasztások (Ki/Be lépés)';

  @override
  String get alertsBattery => 'Alacsony akkumlátor riasztás';

  @override
  String batteryThreshold(int level) {
    return 'Akkumlátor határ: $level%';
  }

  @override
  String get testNotification => 'Értesítés tesztelése';

  @override
  String get testNotifTitle => 'Teszt értesítés';

  @override
  String get testNotifBody => 'Sikeresen beállítottad az értesítéseket!';

  @override
  String get batteryLowTitle => 'Alacsony akkumlátor!';

  @override
  String batteryLowBody(int level) {
    return 'A monitor $level% alá merült.';
  }

  @override
  String get cameraOffline => 'Nincs kamera élőkép';

  @override
  String secondsAgo(int seconds) {
    return '$seconds másodperce';
  }

  @override
  String get toiletZone => 'Alomtálca / WC';

  @override
  String get bedZone => 'Fekvőhely';

  @override
  String get waterZone => 'Itató';

  @override
  String get foodZone => 'Etető';

  @override
  String get playZone => 'Játszótér';

  @override
  String get appearance => 'Megjelenés (Téma)';

  @override
  String get themeSystem => 'Rendszer alapértelmezett';

  @override
  String get themeLight => 'Világos';

  @override
  String get themeDark => 'Sötét';

  @override
  String failedToLoadPetProfile(String e) {
    return 'Nem sikerült betölteni a profilt: $e';
  }

  @override
  String get invalidSecretToken => 'Hibás Secret Token!';

  @override
  String get serverUnreachable => 'Szerver nem elérhető!';

  @override
  String decodingErrorZones(String e) {
    return 'Dekódolási hiba zónáknál: $e';
  }

  @override
  String decodingError(String e) {
    return 'Dekódolási hiba: $e';
  }

  @override
  String profileUploadError(String e) {
    return 'Profil feltöltés hiba: $e';
  }

  @override
  String get setupWelcomeTitle => 'Üdvözöl a PetTrack!';

  @override
  String get setupWelcomeDesc =>
      'A legbiztonságosabb kisállatfigyelő\n\nElső lépésként olvasd be a szerver QR kódját!';

  @override
  String get setupScanBtn => 'QR kód beolvasása';

  @override
  String get setupSuccessTitle => 'Sikeres csatlakozás!';

  @override
  String get setupSuccessDesc =>
      'A kapcsolat titkosítva.\nMost adjuk meg a kedvenced adatait.';

  @override
  String get setupNextBtn => 'Tovább';

  @override
  String get setupPinTitle => 'Webes pin beállítása';

  @override
  String get setupPinDesc =>
      'Hozz létre egy 4 számjegyű PIN kódot a böngészős belépéshez.';

  @override
  String get setupFinishBtn => 'Befejezés és indítás';

  @override
  String get setupErrConnect =>
      'Hiba a szerverhez csatlakozáskor! Ellenőrizd a hálózatot.';

  @override
  String get setupErrSave => 'Hiba a profil mentésekor!';

  @override
  String get setupErrEmpty => 'Adj meg egy nevet és egy 4 számjegyű PIN kódot!';

  @override
  String get setupMonitorTitle => 'Kamera beállítása';

  @override
  String get setupMonitorDesc =>
      'Nyisd meg a Monitor appot a régi telefonodon, és olvasd be ezt a QR kódot a csatlakozáshoz!';

  @override
  String get settingsShowQrBtn => 'QR kód megjelenítése';

  @override
  String get settingsQrDialogDesc => 'Olvasd be a régi telefonnal:';

  @override
  String get settingsQrDialogDone => 'Kész';

  @override
  String get settingsResetApp => 'App alaphelyzetbe állítása';

  @override
  String get settingsResetConfirmTitle => 'Biztos vagy benne?';

  @override
  String get settingsResetConfirmDesc =>
      'Ez minden adatot töröl és újraindítja a beállítási varázslót.';

  @override
  String get serverUnreachableTitle => 'Szerver nem elérhető';

  @override
  String get serverUnreachableDesc =>
      'Nem sikerült csatlakozni a PetTrack szerverhez.\nKérlek ellenőrizd a hálózatot, hogy fut-e a szerver.';
}
