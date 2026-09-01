import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pettrack_app/l10n/app_localizations.dart';
import 'package:pettrack_app/screens/monitor_screen.dart';

class MonitorSetupScreen extends StatefulWidget {
  const MonitorSetupScreen({super.key});

  @override
  State<MonitorSetupScreen> createState() => _MonitorSetupScreenState();
}

class _MonitorSetupScreenState extends State<MonitorSetupScreen> {
  bool _isProcessing = false;
  final _pinController = TextEditingController();
  final _ipController = TextEditingController();
  final _secureStorage = const FlutterSecureStorage();

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
          clientId = 'monitor_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
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

  Future<void> _startDemoMode(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final bool? wantDemo = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.demoModeTitle),
        content: Text(l10n.demoModePrompt),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Yes'),
          ),
        ],
      ),
    );

    if (wantDemo == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', 'demo_ip');
      await prefs.setString('server_token', 'demo_token');
      await prefs.setString('client_id', 'demo_client');
      await prefs.setString('app_mode', 'monitor');
      await _secureStorage.write(key: 'demo_pin', value: '8068');

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const MonitorScreen(
            serverIp: 'demo_ip',
            token: 'demo_token',
            clientId: 'demo_client',
          ),
        ),
      );
    }
  }

  Future<void> _handlePinSubmit() async {
    final pin = _pinController.text.trim();
    final ipInput = _ipController.text.trim();
    if (pin.isEmpty || ipInput.isEmpty) return;

    // Demo logic moved to _startDemoMode()
    
    String targetIp = ipInput;
    if (!targetIp.startsWith('http://') && !targetIp.startsWith('https://')) {
      targetIp = 'http://$targetIp';
    }
    
    final uri = Uri.tryParse(targetIp);
    if (uri != null && !uri.hasPort) {
      // If it's a local IP or localhost, append :8000 by default unless HTTPS
      final host = uri.host;
      final isIpOrLocal = RegExp(r'^(?:[0-9]{1,3}\.){3}[0-9]{1,3}$').hasMatch(host) || host == 'localhost';
      if (isIpOrLocal && uri.scheme != 'https' && !targetIp.contains(':$host')) {
         targetIp = '${uri.scheme}://$host:8000${uri.path}';
      }
    }
    
    _ipController.text = targetIp;
    
    setState(() => _isProcessing = true);
    try {
      final response = await http.post(
        Uri.parse('$targetIp/api/auth/login_pin'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'pin': pin}),
      ).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('server_ip', targetIp);
        await prefs.setString('server_token', data['secret']);

        String clientId = prefs.getString('client_id') ?? '';
        if (clientId.isEmpty) {
          clientId = 'monitor_${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
          await prefs.setString('client_id', clientId);
        }

        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => MonitorScreen(
              serverIp: targetIp,
              token: data['secret'],
              clientId: clientId,
            ),
          ),
        );
      } else {
        throw Exception("Login Failed");
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to connect or invalid PIN')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.setupTitle)),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
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
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          l10n.setupScanQrTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextField(
                            controller: _ipController,
                            decoration: InputDecoration(
                              labelText: l10n.serverIp,
                              hintText: l10n.serverIpHint,
                              border: const OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _pinController,
                                  decoration: InputDecoration(
                                    labelText: l10n.enterPin,
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  maxLength: 4,
                                ),
                              ),
                              const SizedBox(width: 16),
                              ElevatedButton(
                                onPressed: _handlePinSubmit,
                                child: const Text('Submit'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () => _startDemoMode(context),
                            icon: const Icon(Icons.play_circle_fill),
                            label: const Text('Demo Mode'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
      ),
    );
  }
}
