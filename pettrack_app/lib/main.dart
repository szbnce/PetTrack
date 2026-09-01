import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pettrack_app/l10n/app_localizations.dart';
import 'package:camera/camera.dart';

import 'theme/app_theme.dart';
import 'screens/language_screen.dart';
import 'screens/main_navigation.dart';
import 'screens/setup_wizard_screen.dart';
import 'screens/monitor_setup_screen.dart';
import 'screens/monitor_screen.dart';

late List<CameraDescription> _cameras;
List<CameraDescription> get cameras => _cameras;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  PaintingBinding.instance.imageCache.maximumSize = 50;
  PaintingBinding.instance.imageCache.maximumSizeBytes = 20 * 1024 * 1024; // 20 MB

  try {
    _cameras = await availableCameras();
  } catch (e) {
    debugPrint('No cameras found: $e');
    _cameras = [];
  }
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

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
    PetTrackApp(
      initialLocale: savedLocale,
      initialThemeMode: initialThemeMode,
    ),
  );
}

class PetTrackApp extends StatefulWidget {
  final String? initialLocale;
  final ThemeMode initialThemeMode;

  static final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

  const PetTrackApp({
    super.key,
    this.initialLocale,
    this.initialThemeMode = ThemeMode.system,
  });

  static void setLocale(BuildContext context, Locale newLocale) {
    _PetTrackAppState? state = context.findAncestorStateOfType<_PetTrackAppState>();
    state?.setLocale(newLocale);
  }

  static void setThemeMode(BuildContext context, ThemeMode mode) {
    themeNotifier.value = mode;
    _PetTrackAppState? state = context.findAncestorStateOfType<_PetTrackAppState>();
    state?.setThemeMode(mode);
  }

  @override
  State<PetTrackApp> createState() => _PetTrackAppState();
}

class _PetTrackAppState extends State<PetTrackApp> {
  Locale? _locale;
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialThemeMode;
    PetTrackApp.themeNotifier.value = _themeMode;
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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: PetTrackApp.themeNotifier,
      builder: (context, currentMode, child) {
        return MaterialApp(
          title: 'PetTrack',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentMode,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('hu'),
            Locale('zh'),
            Locale('it'),
            Locale('de'),
            Locale('ja'),
            Locale('ko'),
          ],
          locale: _locale,
          home: const BootScreen(),
        );
      },
    );
  }
}

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
    final mode = prefs.getString('app_mode');
    
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (!mounted) return;

    if (mode == null) {
      // First launch
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LanguageScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
      return;
    }

    if (mode == 'client') {
      final ip = prefs.getString('server_ip');
      final token = prefs.getString('jwt_token');
      final petName = prefs.getString('pet_name') ?? '';

      if (ip != null && ip.isNotEmpty && token != null && token.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MainNavigationScreen(
              serverIp: ip,
              token: token,
              petName: petName,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const SetupWizardScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      }
    } else if (mode == 'monitor') {
      final ip = prefs.getString('server_ip');
      final token = prefs.getString('server_token');
      final clientId = prefs.getString('client_id') ?? 'unnamed_monitor';

      if (ip != null && ip.isNotEmpty && token != null && token.isNotEmpty) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => MonitorScreen(
              serverIp: ip,
              token: token,
              clientId: clientId,
            ),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      } else {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const MonitorSetupScreen(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
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
