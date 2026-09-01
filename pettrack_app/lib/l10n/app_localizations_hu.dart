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
  String get settingsTitle => 'Beállítások';

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
  String get navDashboard => 'Kezdőlap';

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
  String get zoneVisits => 'Zone Visits';

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
  String get mostSeen => 'Legtöbbet látott';

  @override
  String get lastUpdated => 'Utoljára frissítve';

  @override
  String get noDataAvailable => 'Nincs adat.';

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
  String get themeLight => 'Világos mód';

  @override
  String get themeDark => 'Sötét mód';

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

  @override
  String get profileAndSystem => 'Profil & Rendszer';

  @override
  String get monitorAndConnection => 'Monitor & Kapcsolat';

  @override
  String get offlineStatus => 'OFFLINE!';

  @override
  String get liveStatus => 'Élő';

  @override
  String get searchingStatus => 'Keresés...';

  @override
  String get navMedical => 'Egészségügy';

  @override
  String get medications => 'Gyógyszerek';

  @override
  String get vaccines => 'Oltások';

  @override
  String get addMedication => 'Gyógyszer felvétele';

  @override
  String get addVaccine => 'Oltás felvétele';

  @override
  String get dose => 'Dózis';

  @override
  String get time => 'Időpont';

  @override
  String get dateGiven => 'Beadás dátuma';

  @override
  String get nextDue => 'Következő esedékes';

  @override
  String get enableAlert => 'Riasztás bekapcsolása';

  @override
  String get medName => 'Gyógyszer neve';

  @override
  String get vacName => 'Oltás neve';

  @override
  String get noMedications => 'Még nincs gyógyszer rögzítve.';

  @override
  String get noVaccines => 'Még nincs oltás rögzítve.';

  @override
  String get saveMedication => 'Gyógyszer mentése';

  @override
  String get saveVaccine => 'Oltás mentése';

  @override
  String get cardColor => 'Kártya színe:';

  @override
  String get alertFrequency => 'Értesítés gyakorisága (órában)';

  @override
  String get alertFrequencyHint => 'pl. 12 vagy 24';

  @override
  String get medTimeTitle => 'Gyógyszer idő!';

  @override
  String medTimeBody(String name, String dose) {
    return 'Ideje beadni: $name ($dose)';
  }

  @override
  String everyXHours(int hours) {
    return 'Minden $hours órában';
  }

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

  @override
  String get welcomeTitle => 'Üdvözöl a PetTrack';

  @override
  String get chooseMode => 'Válassz módot';

  @override
  String get modeClient => 'Kliens (Figyelő)';

  @override
  String get modeClientDesc => 'Ezen az eszközön nézheted a kamerát.';

  @override
  String get modeMonitor => 'Monitor (Kamera)';

  @override
  String get modeMonitorDesc => 'Ez az eszköz fogja közvetíteni a képet.';

  @override
  String get enterPin => 'PIN kód megadása';

  @override
  String get demoModeTitle => 'Demo Mód';

  @override
  String get demoModePrompt => 'Szeretnél belépni a Demo módba?';

  @override
  String get exit => 'Kilépés';

  @override
  String get demoLivePreview => 'DEMO MÓD, ÉLŐKÉP HELYE!';

  @override
  String get loading => 'Loading...';
}
