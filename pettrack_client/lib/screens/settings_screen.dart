import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';
import '../theme/colors.dart';
import '../main.dart';
import 'main_navigation.dart';
import '../services/notification_service.dart';

class SettingsScreen extends StatefulWidget {
  final bool isSetup;
  const SettingsScreen({super.key, this.isSetup = false});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _ipController = TextEditingController();
  final _tokenController = TextEditingController();
  final _petNameController = TextEditingController();
  String? _profilePicBase64;
  String _languageCode = 'hu';
  String _petType = 'rabbit';
  bool _alertsZoneEnabled = true;
  bool _alertsBatteryEnabled = true;
  double _batteryThreshold = 20.0;
  bool _isLoading = true;

  IconData _getPetIcon(String type) {
    switch (type) {
      case 'dog':
        return Icons.pets;
      case 'cat':
        return Icons.pets;
      case 'rabbit':
        return Icons.cruelty_free;
      case 'bird':
        return Icons.flutter_dash;
      case 'guineapig':
        return Icons.pest_control_rodent;
      default:
        return Icons.pets;
    }
  }

  String _getLocalizedPetType(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context)!;
    switch (type) {
      case 'dog':
        return l10n.petTypeDog;
      case 'cat':
        return l10n.petTypeCat;
      case 'rabbit':
        return l10n.petTypeRabbit;
      case 'bird':
        return l10n.petTypeBird;
      case 'guineapig':
        return l10n.petTypeGuineaPig;
      default:
        return l10n.petTypeOther;
    }
  }

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _ipController.text = prefs.getString('server_ip') ?? '';
      _tokenController.text = prefs.getString('server_token') ?? '';
      _petNameController.text = prefs.getString('pet_name') ?? 'Bodri';
      _profilePicBase64 = prefs.getString('profile_pic');
      _languageCode = prefs.getString('language_code') ?? 'hu';
      _petType = prefs.getString('pet_type') ?? 'rabbit';
      _alertsZoneEnabled = prefs.getBool('alerts_zone_enabled') ?? true;
      _alertsBatteryEnabled = prefs.getBool('alerts_battery_enabled') ?? true;
      _batteryThreshold = prefs.getDouble('alerts_battery_threshold') ?? 20.0;
      _isLoading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _profilePicBase64 = base64Encode(bytes);
      });
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_ip', _ipController.text.trim());
    await prefs.setString('server_token', _tokenController.text.trim());
    await prefs.setString('pet_name', _petNameController.text.trim());
    await prefs.setString('language_code', _languageCode);
    await prefs.setString('pet_type', _petType);
    await prefs.setBool('alerts_zone_enabled', _alertsZoneEnabled);
    await prefs.setBool('alerts_battery_enabled', _alertsBatteryEnabled);
    await prefs.setDouble('alerts_battery_threshold', _batteryThreshold);
    if (_profilePicBase64 != null) {
      await prefs.setString('profile_pic', _profilePicBase64!);
    } else {
      await prefs.remove('profile_pic');
    }

    if (mounted) {
      PetTrackClientApp.setLocale(context, Locale(_languageCode));

      if (widget.isSetup) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                MainNavigationScreen(
                  serverIp: _ipController.text.trim(),
                  token: _tokenController.text.trim(),
                  petName: _petNameController.text.trim().isEmpty
                      ? 'Bodri'
                      : _petNameController.text.trim(),
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.save + " OK"),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Text(
                l10n.settingsTitle,
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Profilkép (stilizált)
              GestureDetector(
                onTap: _pickImage,
                onLongPress: () {
                  setState(() {
                    _profilePicBase64 = null;
                  });
                },
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.outline.withOpacity(0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                        color: AppColors.surfaceVariant,
                        image: _profilePicBase64 != null
                            ? DecorationImage(
                                image: MemoryImage(
                                  base64Decode(_profilePicBase64!),
                                ),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: _profilePicBase64 == null
                          ? const Icon(
                              Icons.pets,
                              size: 60,
                              color: AppColors.primary,
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.uploadProfilePicture,
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(color: AppColors.primary),
              ),

              const SizedBox(height: 40),

              // Űrlap
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.outline.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.serverIp,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ipController,
                      decoration: InputDecoration(hintText: l10n.serverIpHint),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l10n.language,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _languageCode,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: 'en',
                              child: Text('English'),
                            ),
                            DropdownMenuItem(
                              value: 'hu',
                              child: Text('Magyar'),
                            ),
                          ],
                          onChanged: (String? newValue) async {
                            if (newValue != null && newValue != _languageCode) {
                              setState(() {
                                _languageCode = newValue;
                              });
                              final prefs =
                                  await SharedPreferences.getInstance();
                              await prefs.setString('language_code', newValue);
                              if (mounted) {
                                PetTrackClientApp.setLocale(
                                  context,
                                  Locale(newValue),
                                );
                              }
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l10n.secretToken,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _tokenController,
                      decoration: const InputDecoration(
                        hintText: '••••••••••••',
                      ),
                      obscureText: true,
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l10n.petName,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _petNameController,
                      decoration: InputDecoration(hintText: l10n.petNameHint),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      l10n.petTypeTitle,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _petType,
                          isExpanded: true,
                          items:
                              [
                                    'dog',
                                    'cat',
                                    'rabbit',
                                    'guineapig',
                                    'bird',
                                    'other',
                                  ]
                                  .map(
                                    (type) => DropdownMenuItem(
                                      value: type,
                                      child: Text(
                                        _getLocalizedPetType(context, type),
                                      ),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _petType = newValue;
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    Text(
                      l10n.alertsTitle,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SwitchListTile(
                      title: Text(l10n.alertsZone),
                      value: _alertsZoneEnabled,
                      onChanged: (val) =>
                          setState(() => _alertsZoneEnabled = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    SwitchListTile(
                      title: Text(l10n.alertsBattery),
                      value: _alertsBatteryEnabled,
                      onChanged: (val) =>
                          setState(() => _alertsBatteryEnabled = val),
                      contentPadding: EdgeInsets.zero,
                    ),
                    if (_alertsBatteryEnabled)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.batteryThreshold(_batteryThreshold.toInt()),
                          ),
                          Slider(
                            value: _batteryThreshold,
                            min: 5,
                            max: 50,
                            divisions: 9,
                            label: "${_batteryThreshold.toInt()}%",
                            onChanged: (val) =>
                                setState(() => _batteryThreshold = val),
                          ),
                        ],
                      ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final notifService = NotificationService();
                        await notifService.requestPermissions();
                        await notifService.showNotification(
                          id: 999,
                          title: l10n.testNotifTitle,
                          body: l10n.testNotifBody,
                        );
                      },
                      icon: const Icon(Icons.notifications_active),
                      label: Text(l10n.testNotification),
                    ),

                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _save,
                        icon: const Text(''), // Spacer
                        label: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.save,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(Icons.check, size: 20),
                          ],
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
