import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
// KIVÁGTUK A FRANCBA A WEB SOCKET CHANNEL IMPORTOT! 🗑️

late List<CameraDescription> _cameras;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _cameras = await availableCameras();
  runApp(const PetTrackApp());
}

class PetTrackApp extends StatelessWidget {
  const PetTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PetTrack Monitor',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red[900],
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const SetupScreen(),
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

  @override
  void initState() {
    super.initState();
    _loadSavedIp();
  }

  Future<void> _loadSavedIp() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('server_ip') ?? '127.0.0.1:8000';
      _tokenController.text = prefs.getString('server_token') ?? 'MYSUPERSECRETTOKEN';
    });
  }

  Future<void> _saveAndStart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text);
    await prefs.setString('server_token', _tokenController.text);

    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MonitorScreen(
          serverIp: _ipController.text,
          token: _tokenController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🐾 PetTrack Setup'),
        backgroundColor: Colors.red[900],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.warning_amber_rounded, size: 60, color: Colors.orange),
            const SizedBox(height: 10),
            const Text(
              'Next step',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
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
                labelText: 'Backend Server IP and Port',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
              keyboardType: TextInputType.url,
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
              label: const Text('Start MONITOR', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

// MonitorScreen 
class MonitorScreen extends StatefulWidget {
  final String serverIp;
  final String token;
  const MonitorScreen({super.key, required this.serverIp, required this.token});

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

  @override
  void initState() {
    super.initState();
    _initCamera();
    _connectWebSocket();
  }

  Future<void> _initCamera() async {
    try {
      _controller = CameraController(
        _cameras[0],
        ResolutionPreset.low,
        enableAudio: false,
      );

      await _controller.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    } catch (e) {
      debugPrint('Camera initialization failed: $e');
    }
  }

  // Ez a függvény mostantól async, és a natív Socketet használja!
  Future<void> _connectWebSocket() async {
    try {
      debugPrint("Connecting to ws://${widget.serverIp}/ws");
      _socket = await WebSocket.connect('ws://${widget.serverIp}/ws?token=${widget.token}');
      debugPrint("Connected successfully!");

      // Figyeljük a szerver utasításait
      _socket!.listen((message) {
        if (message == "START") {
          _startStreaming();
        } else if (message == "STOP") {
          _stopStreaming();
        }
      }, onDone: () {
        debugPrint("Server disconnected!");
        _stopStreaming();
      }, onError: (error) {
        debugPrint("WebSocket error: $error");
        _stopStreaming();
      });
    } catch (e) {
      debugPrint("Failed to connect: $e");
    }
  }

  bool _isCapturing = false;

  void _startStreaming() {
    if (_isStreaming || !_isInitialized || _socket == null) return;

    setState(() => _isStreaming = true);
    WakelockPlus.enable();
    debugPrint("Starting Stream");

    // 10 FPS = 100 milliszekundum
    _streamTimer = Timer.periodic(const Duration(milliseconds: 100), (_) async {
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
    if (!_controller.value.isInitialized || !_isStreaming || _socket == null) return;

    _isCapturing = true;
    try {
      // takePicture() fájlba menti a képet a háttérben
      final picture = await _controller.takePicture();
      final bytes = await picture.readAsBytes();
      
      if (_socket?.readyState == WebSocket.open) {
        _socket!.add(bytes);
      }
      
      // Töröljük a fájlt, hogy ne teljen meg a telefon tárhelye másodpercek alatt!
      File(picture.path).delete().catchError((_) {});
      
    } catch (e) {
      debugPrint("Failed to capture or send frame: $e");
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
    if (_isSleeping) {
      return GestureDetector(
        onDoubleTap: () => setState(() => _isSleeping = false),
        child: const Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Text(
              'Sleeping... Double tap to wake',
              style: TextStyle(color: Colors.white24, fontSize: 12),
            ),
          ),
        ),
      );
    }

    return Scaffold(
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
        ],
      ),
      body: _isInitialized
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AspectRatio(
                  aspectRatio: _controller.value.aspectRatio,
                  child: CameraPreview(_controller),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        _isStreaming ? 'Streaming live video...' : 'Waiting for START command...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _isStreaming ? null : _startStreaming,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            child: const Text('Start'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: _isStreaming ? _stopStreaming : null,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Stop'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Server: ${widget.serverIp}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 14, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
