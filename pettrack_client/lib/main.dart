import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';

import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'screens/main_navigation.dart';
import 'screens/settings_screen.dart'; // We use settings screen as setup initially if not logged in

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final savedLocale = prefs.getString('language_code') ?? 'hu';
  final themeModeString = prefs.getString('theme_mode') ?? 'system';

  ThemeMode initialThemeMode;
  switch (themeModeString) {
    case 'light':
      initialThemeMode = ThemeMode.light;
      break;
    case 'dark':
      initialThemeMode = ThemeMode.dark;
      break;
    case 'system':
    default:
      initialThemeMode = ThemeMode.system;
  }

  runApp(
    PetTrackClientApp(
      initialLocale: savedLocale,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class PetTrackClientApp extends StatefulWidget {
  final String? initialLocale;
  final ThemeMode initialThemeMode;
  const PetTrackClientApp({
    super.key,
    this.initialLocale,
    this.initialThemeMode = ThemeMode.system,
  });

  static void setLocale(BuildContext context, Locale newLocale) {
    _PetTrackClientAppState? state = context
        .findAncestorStateOfType<_PetTrackClientAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    _PetTrackClientAppState? state = context
        .findAncestorStateOfType<_PetTrackClientAppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<PetTrackClientApp> createState() => _PetTrackClientAppState();
}

class _PetTrackClientAppState extends State<PetTrackClientApp> {
  Locale? _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    if (widget.initialLocale != null) {
      _locale = Locale(widget.initialLocale!);
    }
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetTrack Client',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: _themeMode,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('hu'), // Hungarian
      ],
      locale: _locale,
      home: const BootScreen(),
    );
  }
}

// ----------------------------------------------------------------------
// BOOT SCREEN (Betöltés & Ellenőrzés)
// ----------------------------------------------------------------------
class BootScreen extends StatefulWidget {
  const BootScreen({super.key});

  @override
  State<BootScreen> createState() => _BootScreenState();
}

class _BootScreenState extends State<BootScreen> {
  @override
  void initState() {
    super.initState();
    _checkSetup();
  }

  Future<void> _checkSetup() async {
    final prefs = await SharedPreferences.getInstance();
    final ip = prefs.getString('server_ip');
    final token = prefs.getString('server_token');
    final petName = prefs.getString('pet_name') ?? 'Bodri';

    await Future.delayed(const Duration(milliseconds: 800));

    if (ip != null && ip.isNotEmpty && token != null && token.isNotEmpty) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainNavigationScreen(
                  serverIp: ip,
                  token: token,
                  petName: petName,
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                const SetupScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Theme.of(context).colorScheme.surface,
    body: Center(
      child: CircularProgressIndicator(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}

// ----------------------------------------------------------------------
// SETUP SCREEN (Csak induláskor, ha nincs adat)
// ----------------------------------------------------------------------
class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SettingsScreen(isSetup: true);
  }
}
