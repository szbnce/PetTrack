import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/rendering.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter/services.dart';
import 'dart:ui' as ui;

late List<CameraDescription> _cameras;

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
    return MaterialApp(
      title: 'PetTrack Monitor',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[900],
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),

      home: skipSetup
          ? MonitorScreen(
              serverIp: initialIp!,
              token: initialToken!,
              clientId: initialClientId,
            )
          : const SetupScreen(),
    );
  }
}

// SetupScreen
class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final TextEditingController _ipController = TextEditingController();
  final TextEditingController _tokenController = TextEditingController();
  final TextEditingController _clientIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('server_ip') ?? '127.0.0.1:8000';
      _tokenController.text =
          prefs.getString('server_token') ?? 'MYSUPERSECRETTOKEN';
      _clientIdController.text =
          prefs.getString('client_id') ?? 'unnamed_monitor';
    });
  }

  Future<void> _saveAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text);
    await prefs.setString('server_token', _tokenController.text);
    await prefs.setString('client_id', _clientIdController.text);

    if (!mounted) return;

    if (Navigator.canPop(context)) {
      // Ha a Monitor képernyőről jöttünk, csak visszalépünk
      Navigator.pop(context, true);
    } else {
      // Ha frissen indult az app, betöltjük a Monitort
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MonitorScreen(
            serverIp: _ipController.text,
            token: _tokenController.text,
            clientId: _clientIdController.text,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 PetTrack Setup'),
        backgroundColor: Colors.red[900],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 60,
                  color: Colors.orange,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Next step',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Before you start this, go out from the app, go into the app information and turn on Autostart for this to work!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 40),
                TextField(
                  controller: _ipController,
                  decoration: const InputDecoration(
                    labelText: 'Backend server IP and Port',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.computer),
                  ),
                  keyboardType: TextInputType.url,
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _clientIdController,
                  decoration: const InputDecoration(
                    labelText: 'Device Name (Monitor ID)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _tokenController,
                  decoration: const InputDecoration(
                    labelText: 'Security Token',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.security),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveAndStart,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    padding: const EdgeInsets.symmetric(vertical: 15),
                  ),
                  icon: const Icon(Icons.camera_alt),
                  label: const Text(
                    'Save & Start',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// MonitorScreen
class MonitorScreen extends StatefulWidget {
  final String serverIp;
  final String token;
  final String clientId;
  const MonitorScreen({super.key, required this.serverIp, required this.token, required this.clientId});

  @override
  State<MonitorScreen> createState() => _MonitorScreenState();
}

class _MonitorScreenState extends State<MonitorScreen> {
  late CameraController _controller;

  // Itt jön a natív mágia a Channel helyett! 🔌
  WebSocket? _socket;
  bool _isInitialized = false;
  bool _isStreaming = false;
  bool _isSleeping = false;
  Timer? _streamTimer;
  bool _isCapturing = false;
  final GlobalKey _previewKey = GlobalKey();
  final GlobalKey _cameraKey = GlobalKey();

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

  // Ez a függvény mostantól async, és a natív Socketet használja!
  Future<void> _connectWebSocket() async {
    if (!mounted) return;

    try {
      debugPrint("Connecting to ws://$_currentIp/ws");
      _socket = await WebSocket.connect(
        'ws://$_currentIp/ws?token=$_currentToken&client_id=$_currentClientId',
      ).timeout(const Duration(seconds: 5));

      debugPrint("Connected successfully!");

      // Figyeljük a szerver utasításait
      _socket!.listen(
        (message) {
          if (message == "START") {
            _startStreaming();
          } else if (message == "STOP") {
            _stopStreaming();
          }
        },
        onDone: () {
          debugPrint("Server disconnected!");
          _stopStreaming();
        },
        onError: (error) {
          debugPrint("WebSocket error: $error");
          _stopStreaming();
        },
      );
    } catch (e) {
      debugPrint("Failed to connect: $e");
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
    if (_isStreaming || !_isInitialized) return;

    setState(() => _isStreaming = true);
    WakelockPlus.enable();
    debugPrint("Starting Stream");

    _streamTimer = Timer.periodic(const Duration(milliseconds: 2000), (
      _,
    ) async {
      if (!_isCapturing) {
        await _captureAndSendFrame();
      }
    });
  }

  void _stopStreaming() {
    if (!_isStreaming) return;

    _streamTimer?.cancel();
    _streamTimer = null;

    setState(() {
      _isStreaming = false;
      _isSleeping = false;
    });
    WakelockPlus.disable();
    debugPrint("Stopping Stream");
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
    _controller.dispose();
    _socket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mainScreen = Scaffold(
      appBar: AppBar(
        title: const Text('🐾 Monitor'),
        backgroundColor: Colors.red[900],
        actions: [
          if (_isStreaming)
            IconButton(
              icon: const Icon(Icons.bedtime),
              tooltip: 'Sleep Mode (Dim Screen)',
              onPressed: () => setState(() => _isSleeping = true),
            ),

          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'settings') {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SetupScreen()),
                );

                // Ha visszajöttünk a beállításokból és elmentették
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
                  applicationVersion: 'Alpha',
                  applicationIcon: const Icon(
                    Icons.pets,
                    size: 50,
                    color: Colors.orange,
                  ),
                  children: [
                    const Text(
                      'This app securely streams your camera feed to the PetTrack backend for analysis.',
                    ),
                  ],
                );
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                const PopupMenuItem(value: 'settings', child: Text('Settings')),
                const PopupMenuItem(value: 'about', child: Text('About')),
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
                  child: Center(
                    child: RepaintBoundary(
                      key: _cameraKey,
                      child: CameraPreview(_controller),
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
                              ? 'Streaming live video...'
                              : 'Waiting for START command...',
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
                                backgroundColor: Colors.green,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'Start',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _isStreaming ? _stopStreaming : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text(
                                'stop',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Server:\n${widget.serverIp}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.white70,
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
            child: const Center(
              child: DefaultTextStyle(
                style: TextStyle(color: Colors.white24, fontSize: 12),
                child: Text('Sleeping... Double tap to wake'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
