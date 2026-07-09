import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;
import 'package:battery_plus/battery_plus.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'theme/app_theme.dart';
import 'theme/colors.dart';
import 'l10n/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

late List<CameraDescription> _cameras;
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.dark);
final ValueNotifier<Locale?> localeNotifier = ValueNotifier(null);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  _cameras = await availableCameras();

  final prefs = await SharedPreferences.getInstance();
  final savedIp = prefs.getString('server_ip');
  final savedToken = prefs.getString('server_token');
  final savedClientId = prefs.getString('client_id');

  final savedTheme = prefs.getString('theme_mode');
  if (savedTheme == 'light') {
    themeNotifier.value = ThemeMode.light;
  } else {
    themeNotifier.value = ThemeMode.dark;
  }

  final savedLang = prefs.getString('language_code');
  if (savedLang != null) {
    localeNotifier.value = Locale(savedLang);
  }

  final bool skipSetup = savedIp != null && savedIp.isNotEmpty;

  runApp(
    PetTrackApp(
      skipSetup: skipSetup,
      initialIp: savedIp,
      initialToken: savedToken,
      initialClientId: savedClientId ?? 'unnamed_monitor',
    ),
  );
}

class PetTrackApp extends StatelessWidget {
  final bool skipSetup;
  final String? initialIp;
  final String? initialToken;
  final String initialClientId;

  const PetTrackApp({
    super.key,
    required this.skipSetup,
    this.initialIp,
    this.initialToken,
    required this.initialClientId,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, child) {
        return ValueListenableBuilder<Locale?>(
          valueListenable: localeNotifier,
          builder: (context, currentLocale, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: "PetTrack Monitor",
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: currentMode,

              locale: currentLocale,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,

              home: skipSetup
                  ? MonitorScreen(
                      serverIp: initialIp!,
                      token: initialToken!,
                      clientId: initialClientId,
                    )
                  : const SetupScreen(),
            );
          },
        );
      },
    );
  }
}

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  bool _isProcessing = false;

  Future<void> _handleScan(String rawData) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final data = jsonDecode(rawData);
      if (data['ip'] != null && data['secret'] != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_ip', data['ip']);
        await prefs.setString('server_token', data['secret']);

        String clientId = prefs.getString('client_id') ?? '';
        if (clientId.isEmpty) {
          clientId =
              'monitor_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
          await prefs.setString('client_id', clientId);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MonitorScreen(
              serverIp: data['ip'],
              token: data['secret'],
              clientId: clientId,
            ),
          ),
        );
      } else {
        setState(() => _isProcessing = false);
      }
    } catch (e) {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _handleScan(barcode.rawValue!);
                  break;
                }
              }
            },
          ),
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    l10n.setupScanQrTitle,
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          if (_isProcessing)
            Container(
              color: Colors.black54,
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}

// MonitorScreen
class MonitorScreen extends StatefulWidget {
  final String serverIp;
  final String token;
  final String clientId;
  const MonitorScreen({
    super.key,
    required this.serverIp,
    required this.token,
    required this.clientId,
  });

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  late CameraController _controller;

  WebSocket? _socket;
  bool _isInitialized = false;
  bool _isStreaming = false;
  bool _isSleeping = false;
  Timer? _streamTimer;
  bool _isCapturing = false;
  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _cameraKey = GlobalKey();
  final Battery _battery = Battery();
  Timer? _statusTimer;
  Timer? _reconnectTimer;
  bool _shouldStream = false;
  bool _isReconnecting = false;

  late String _currentIp;
  late String _currentToken;
  late String _currentClientId;

  @override
  void initState() {
    super.initState();
    _currentIp = widget.serverIp;
    _currentToken = widget.token;
    _currentClientId = widget.clientId;
    _initCamera();
    _connectWebSocket();
  }

  Future<void> _initCamera() async {
    try {
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      await _controller.initialize();
      await _controller.setFlashMode(FlashMode.off);
      await _controller.setFocusMode(FocusMode.auto);
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  void _scheduleReconnect() {
    if (!mounted) return;
    setState(() => _isReconnecting = true);
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), () {
      debugPrint("Attempting to reconnect...");
      _connectWebSocket();
    });
  }

  Future<void> _connectWebSocket() async {
    if (!mounted) return;

    try {
      debugPrint("Connecting to ws://$_currentIp/ws");
      _socket = await WebSocket.connect(
        'ws://$_currentIp/ws?token=$_currentToken&client_id=$_currentClientId',
      ).timeout(const Duration(seconds: 5));

      debugPrint("Connected successfully!");
      _reconnectTimer?.cancel();
      if (mounted) setState(() => _isReconnecting = false);

      if (_shouldStream) {
        _startStreaming();
      }

      _socket!.listen(
        (message) {
          if (message == "START") {
            _startStreaming();
          } else if (message == "STOP") {
            _stopStreaming(isManual: true);
          }
        },
        onDone: () {
          debugPrint("Server disconnected!");
          _stopStreaming(isManual: false);
          _scheduleReconnect();
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _stopStreaming(isManual: false);
          _scheduleReconnect();
        },
      );
    } catch (e) {
      debugPrint("Failed to connect: $e");
      _scheduleReconnect();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to connect to server! Check IP and Token.\nError: $e',
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _startStreaming() {
    _shouldStream = true;
    if (_isStreaming || !_isInitialized) return;

    setState(() => _isStreaming = true);
    WakelockPlus.enable();
    debugPrint("Starting Stream");

    _sendBatteryStatus();
    _statusTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _sendBatteryStatus();
    });

    _streamTimer = Timer.periodic(const Duration(milliseconds: 2000), (
      _,
    ) async {
      if (!_isCapturing) {
        await _captureAndSendFrame();
      }
    });
  }

  void _stopStreaming({bool isManual = false}) {
    if (isManual) {
      _shouldStream = false;
    }
    if (!_isStreaming) return;

    _streamTimer?.cancel();
    _streamTimer = null;
    _statusTimer?.cancel();
    _statusTimer = null;

    setState(() {
      _isStreaming = false;
      _isSleeping = false;
    });
    WakelockPlus.disable();
    debugPrint("Stopping Stream");
  }

  Future<void> _sendBatteryStatus() async {
    if (!_isStreaming) return;
    try {
      final level = await _battery.batteryLevel;
      final state = await _battery.batteryState;
      final isCharging =
          state == BatteryState.charging || state == BatteryState.full;

      await http.post(
        Uri.parse('http://$_currentIp/api/monitor/update'),
        headers: {
          'x-api-token': _currentToken,
          'Content-Type': 'application/json',
        },
        body: json.encode({'battery_level': level, 'is_charging': isCharging}),
      );
    } catch (e) {
      debugPrint("Failed to send battery Status: $e");
    }
  }

  Future<void> _captureAndSendFrame() async {
    if (!_controller.value.isInitialized || !_isStreaming || _socket == null) {
      return;
    }

    _isCapturing = true;
    try {
      final boundary =
          _cameraKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 1.0);

      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final bytes = byteData?.buffer.asUint8List();

      if (bytes != null && _socket?.readyState == WebSocket.open) {
        _socket!.add(bytes);
      }
    } catch (e) {
      debugPrint("Capture Failed: $e");
    } finally {
      _isCapturing = false;
    }
  }

  @override
  void dispose() {
    _streamTimer?.cancel();
    _statusTimer?.cancel();
    _reconnectTimer?.cancel();
    _controller.dispose();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final mainScreen = Scaffold(
      appBar: AppBar(
        title: Text(l10n.monitorTitle),
        actions: [
          if (_isStreaming)
            IconButton(
              icon: const Icon(Icons.bedtime),
              tooltip: l10n.monitorSleepMode,
              onPressed: () => setState(() => _isSleeping = true),
            ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'theme') {
                final isDark = themeNotifier.value == ThemeMode.dark;
                themeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('theme_mode', isDark ? 'light' : 'dark');
              } else if (value == 'settings') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupScreen()),
                );

                if (result == true && mounted) {
                  final prefs = await SharedPreferences.getInstance();
                  setState(() {
                    _currentIp = prefs.getString('server_ip') ?? _currentIp;
                    _currentToken =
                        prefs.getString('server_token') ?? _currentToken;
                    _currentClientId =
                        prefs.getString('client_id') ?? _currentClientId;
                  });
                  _socket?.close();
                  _connectWebSocket();
                }
              } else if (value == 'about') {
                showAboutDialog(
                  context: context,
                  applicationName: 'PetTrack Monitor',
                  applicationVersion: 'v1.0 Pre-Release',
                  applicationIcon: const Icon(
                    Icons.pets,
                    size: 50,
                    color: Colors.orange,
                  ),
                  children: [Text(l10n.aboutDescription)],
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'theme',
                  child: Text(
                    themeNotifier.value == ThemeMode.dark
                        ? '☀️ Light Mode'
                        : '🌙 Dark Mode',
                  ),
                ),
                PopupMenuItem(
                  value: 'settings',
                  child: Text(l10n.settingsTitle),
                ),
                PopupMenuItem(value: 'about', child: Text(l10n.aboutTitle)),
              ];
            },
          ),
        ],
      ),
      body: _isInitialized
          ? Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsetsGeometry.all(16.0),
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.5),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadiusGeometry.circular(14),
                          child: RepaintBoundary(
                            key: _cameraKey,
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          _isStreaming
                              ? l10n.monitorStreamingLive
                              : _isReconnecting
                              ? l10n.monitorReconnecting
                              : l10n.monitorWaitingForStart,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _isStreaming ? null : _startStreaming,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.success,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                l10n.start,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isStreaming
                                  ? () => _stopStreaming(isManual: true)
                                  : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: Text(
                                l10n.stop,
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          l10n.monitorServer(widget.serverIp),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );

    if (!_isSleeping) {
      return mainScreen;
    }

    return Stack(
      children: [
        mainScreen,
        GestureDetector(
          onDoubleTap: () => setState(() => _isSleeping = false),
          child: Container(
            color: Colors.black,
            width: double.infinity,
            height: double.infinity,
            child: Center(
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white24, fontSize: 12),
                child: Text(l10n.monitorSleeping),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
