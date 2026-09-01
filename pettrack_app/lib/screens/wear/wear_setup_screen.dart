import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/wear_sync_service.dart';
import 'wear_dashboard_screen.dart';

class WearSetupScreen extends StatefulWidget {
  const WearSetupScreen({super.key});

  @override
  State<WearSetupScreen> createState() => _WearSetupScreenState();
}

class _WearSetupScreenState extends State<WearSetupScreen> {
  bool _isSyncing = false;

  @override
  void initState() {
    super.initState();
    _listenForSync();
  }

  void _listenForSync() {
    WearSyncService().listenForCredentials((ip, token) {
      if (mounted) {
        setState(() {
          _isSyncing = true;
        });

        // Add a slight delay for visual effect
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => WearDashboardScreen(serverIp: ip, token: token),
              ),
            );
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _isSyncing ? Icons.check_circle : Icons.watch,
                color: _isSyncing ? Colors.green : Colors.white,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                _isSyncing ? "Szinkronizálva!" : "Nyisd meg az appot a telefonon.",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              if (!_isSyncing)
                const CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 2,
                ),
              if (!_isSyncing) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const WearManualSetupScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Manuális', style: TextStyle(color: Colors.white, fontSize: 12)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class WearManualSetupScreen extends StatefulWidget {
  const WearManualSetupScreen({super.key});

  @override
  State<WearManualSetupScreen> createState() => _WearManualSetupScreenState();
}

class _WearManualSetupScreenState extends State<WearManualSetupScreen> {
  final _ipController = TextEditingController();
  final _tokenController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Beállítás',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ipController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Szerver IP',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _tokenController,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: InputDecoration(
                  hintText: '4-jegyű PIN',
                  counterText: '',
                  hintStyle: const TextStyle(color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[900],
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.red),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey[900]),
                  ),
                  IconButton(
                    onPressed: () async {
                      if (_ipController.text.isEmpty || _tokenController.text.isEmpty) return;
                      
                      String targetIp = _ipController.text.trim();
                      if (!targetIp.startsWith('http://') && !targetIp.startsWith('https://')) {
                        targetIp = 'http://$targetIp';
                      }

                      final uri = Uri.tryParse(targetIp);
                      if (uri != null && !uri.hasPort) {
                        final host = uri.host;
                        final isIpOrLocal = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$').hasMatch(host) || host == 'localhost';
                        if (isIpOrLocal && uri.scheme != 'https' && !targetIp.contains(':$host')) {
                          targetIp = '${uri.scheme}://$host:8000${uri.path}';
                        }
                      }

                      try {
                        final response = await http
                            .post(
                              Uri.parse('$targetIp/api/auth/login_pin'),
                              headers: {'Content-Type': 'application/json'},
                              body: jsonEncode({'pin': _tokenController.text.trim()}),
                            )
                            .timeout(const Duration(seconds: 3));

                        if (response.statusCode == 200) {
                          final data = jsonDecode(response.body);
                          final token = data['secret']; // JWT token
                          if (token != null) {
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setString('server_ip', targetIp);
                            await prefs.setString('api_token', token);
                            if (mounted) {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (_) => WearDashboardScreen(
                                    serverIp: targetIp,
                                    token: token,
                                  ),
                                ),
                              );
                            }
                          }
                        } else {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Hibás PIN!')),
                            );
                          }
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hálózati hiba!')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.check, color: Colors.green),
                    style: IconButton.styleFrom(backgroundColor: Colors.grey[900]),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
