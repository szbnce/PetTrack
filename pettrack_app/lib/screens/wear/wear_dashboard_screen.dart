import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

class WearDashboardScreen extends StatefulWidget {
  final String serverIp;
  final String token;

  const WearDashboardScreen({
    super.key,
    required this.serverIp,
    required this.token,
  });

  @override
  State<WearDashboardScreen> createState() => _WearDashboardScreenState();
}

class _WearDashboardScreenState extends State<WearDashboardScreen> {
  String _petName = 'Betöltés...';
  String _batteryLevel = '--';
  String _currentZone = '--';
  bool _isLoading = true;
  Timer? _timer;
  
  WebSocketChannel? _clientChannel;
  ui.Image? _currentUiImage;
  DateTime? _lastFrameTime;

  @override
  void initState() {
    super.initState();
    _fetchData();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _fetchData());
    _connectWebSocket();
  }

  void _connectWebSocket() {
    try {
      final wsUrl = '${widget.serverIp.replaceAll("http", "ws")}/ws/client?token=${widget.token}';
      _clientChannel = WebSocketChannel.connect(Uri.parse(wsUrl));
      _clientChannel!.stream.listen((data) {
        if (!mounted) return;
        
        // Frissítés 5 másodpercenként (throttling)
        final now = DateTime.now();
        if (_lastFrameTime != null && now.difference(_lastFrameTime!).inSeconds < 5) {
            return;
        }

        try {
          if (data is String) return;
          final newBytes = data is Uint8List ? data : Uint8List.fromList(data as List<int>);
          ui.decodeImageFromList(newBytes, (ui.Image img) {
            if (mounted) {
              setState(() {
                _currentUiImage?.dispose();
                _currentUiImage = img;
                _lastFrameTime = now;
              });
            } else {
              img.dispose();
            }
          });
        } catch (_) {}
      });
    } catch (_) {}
  }

  @override
  void dispose() {
    _timer?.cancel();
    _clientChannel?.sink.close();
    _currentUiImage?.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    try {
      final response = await http
          .get(
            Uri.parse('${widget.serverIp}/api/pet'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 3));

      if (response.statusCode == 200 && mounted) {
        final data = jsonDecode(response.body);
        setState(() {
          _petName = data['name'] ?? 'Kedvenc';
        });
      }

      final statusResp = await http
          .get(
            Uri.parse('${widget.serverIp}/api/status'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 3));

      if (statusResp.statusCode == 200 && mounted) {
        final data = jsonDecode(statusResp.body);
        setState(() {
          _batteryLevel = data['battery_level']?.toString() ?? '--';
        });
      }

      final actResp = await http
          .get(
            Uri.parse('${widget.serverIp}/api/activity?limit=1'),
            headers: {'x-api-token': widget.token},
          )
          .timeout(const Duration(seconds: 3));

      if (actResp.statusCode == 200 && mounted) {
        final data = jsonDecode(actResp.body);
        if (data['events'] != null) {
          final events = data['events'] as List;
          if (events.isNotEmpty) {
            setState(() {
              _currentZone = events[0]['zone_name'] ?? '--';
            });
          }
        }
      }
    } catch (_) {
      // ignore
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.pets, color: Colors.teal, size: 24),
                  const SizedBox(height: 8),
                  Text(
                    _petName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Live View
                  if (_currentUiImage != null)
                    Container(
                      width: double.infinity,
                      height: 120, // Watch height
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey[800]!),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: InteractiveViewer(
                          panEnabled: true,
                          scaleEnabled: true,
                          minScale: 1.0,
                          maxScale: 4.0,
                          child: RawImage(
                            image: _currentUiImage!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),

                  // Battery Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2128),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.battery_std,
                          color: Colors.green,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$_batteryLevel%",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Zone Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E2128),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.orange,
                          size: 20,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _currentZone,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }
}
