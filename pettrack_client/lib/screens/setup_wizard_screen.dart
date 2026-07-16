import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';
import 'qr_scanner_screen.dart';
import 'main_navigation.dart';

class SetupWizardScreen extends StatefulWidget {
  const SetupWizardScreen({super.key});

  @override
  State<SetupWizardScreen> createState() => _SetupWizardScreenState();
}

class _SetupWizardScreenState extends State<SetupWizardScreen> {
  final PageController _pageController = PageController();

  String? _serverIp;
  String? _secretToken;
  String? _jwtToken;

  final _nameController = TextEditingController();
  String _selectedType = 'dog';

  bool _isLoading = false;
  Timer? _monitorPollTimer;

  final List<String> _petTypes = [
    'dog',
    'cat',
    'rabbit',
    'guineaPig',
    'bird',
    'other',
  ];

  String _getTranslatedType(String typeKey, AppLocalizations l10n) {
    switch (typeKey) {
      case 'dog':
        return l10n.petTypeDog;
      case 'cat':
        return l10n.petTypeCat;
      case 'rabbit':
        return l10n.petTypeRabbit;
      case 'guineaPig':
        return l10n.petTypeGuineaPig;
      case 'bird':
        return l10n.petTypeBird;
      case 'other':
        return l10n.petTypeOther;
      default:
        return l10n.unknown;
    }
  }

  Future<void> _startQRscan() async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const QRScannerScreen()));

    if (result != null && result is Map<String, dynamic>) {
      setState(() => _isLoading = true);
      try {
        final ip = result['ip'];
        final secret = result['secret'];

        final response = await http
            .post(
              Uri.parse('http://$ip/api/auth/login'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({'secret': secret}),
            )
            .timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);

          setState(() {
            _serverIp = ip;
            _secretToken = secret;
            _jwtToken = data['token'];
            _isLoading = false;
          });

          _pageController.nextPage(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          throw Exception("Login Failed");
        }
      } catch (e) {
        setState(() => _isLoading = false);
        if (mounted) {
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(l10n.setupErrConnect)));
        }
      }
    }
  }

  void _dispose() {
    _nameController.dispose();
  }

  Future<void> _finishSetup() async {
    final l10n = AppLocalizations.of(context)!;

    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.setupErrEmpty)));
      return;
    }

    setState(() => _isLoading = true);

    try {
      await http.post(
        Uri.parse('http://$_serverIp/api/pet'),
        headers: {
          'Content-Type': 'application/json',
          'x-api-token': _jwtToken!,
        },
        body: jsonEncode({'name': _nameController.text, 'type': _selectedType}),
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('server_ip', _serverIp!);
      await prefs.setString('secret_token', _secretToken!);
      await prefs.setString('jwt_token', _jwtToken!);
      await prefs.setString('pet_name', _nameController.text.trim());
      await prefs.setString('pet_type', _selectedType);

      if (mounted) {
        setState(() => _isLoading = false);
        _pageController.nextPage(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startMonitorPolling();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.setupErrSave)));
      }
    }
  }

  void _startMonitorPolling() {
    _monitorPollTimer = Timer.periodic(const Duration(seconds: 2), (
      timer,
    ) async {
      try {
        final response = await http
            .get(
              Uri.parse('http://$_serverIp/api/status'),
              headers: {'x-api-token': _jwtToken!},
            )
            .timeout(const Duration(seconds: 2));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['monitor_online'] == true) {
            timer.cancel();

            final prefs = await SharedPreferences.getInstance();
            await prefs.setBool('is_setup_completed', true);

            if (mounted) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => MainNavigationScreen(
                    serverIp: _serverIp!,
                    token: _jwtToken!,
                    petName: _nameController.text,
                  ),
                ),
              );
            }
          }
        }
      } catch (e) {
        // ignore
      }
    });
  }

  @override
  void dispose() {
    _monitorPollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildPage(
            title: l10n.setupWelcomeTitle,
            description: l10n.setupWelcomeDesc,
            icon: Icons.qr_code_scanner,
            actionButton: _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton.icon(
                    onPressed: _startQRscan,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      l10n.setupScanBtn,
                      style: const TextStyle(fontSize: 18),
                    ),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
          ),

          _buildPage(
            title: l10n.setupSuccessTitle,
            description: l10n.setupSuccessDesc,
            icon: Icons.pets,
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.petName,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _selectedType,
                  decoration: InputDecoration(
                    labelText: l10n.petTypeTitle,
                    border: const OutlineInputBorder(),
                  ),
                  items: _petTypes.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(_getTranslatedType(value, l10n)),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedType = newValue!;
                    });
                  },
                ),
              ],
            ),
            actionButton: ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _finishSetup();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 15,
                ),
              ),
              child: Text(
                l10n.setupNextBtn,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ),

          _buildPage(
            title: l10n.setupMonitorTitle,
            description: l10n.setupMonitorDesc,
            icon: Icons.camera_indoor,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: jsonEncode({"ip": "$_serverIp", "secret": _secretToken}),
                version: QrVersions.auto,
                size: 200.0,
              ),
            ),
            actionButton: const CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }


  Widget _buildPage({
    required String title,
    required String description,
    required IconData icon,
    required Widget actionButton,
    Widget? child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ?child,
          if (child != null) const SizedBox(height: 32),
          actionButton,
        ],
      ),
    );
  }
}
