import 'package:flutter/material.dart';
import 'package:pettrack_client/l10n/app_localizations.dart';
import '../theme/colors.dart';
import 'dashboard_screen.dart';
import 'zones_screen.dart';
import 'settings_screen.dart';
import 'medical_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  final String serverIp;
  final String token;
  final String petName;

  const MainNavigationScreen({
    super.key,
    required this.serverIp,
    required this.token,
    required this.petName,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        serverIp: widget.serverIp,
        token: widget.token,
        petName: widget.petName,
      ),
      ZonesScreen(serverIp: widget.serverIp, token: widget.token),
      const MedicalScreen(),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String getTitle() {
      switch (_selectedIndex) {
        case 0:
          return l10n.appName;
        case 1:
          return l10n.navZones;
        case 2:
          return l10n.navMedical;
        case 3:
          return l10n.navSettings;
        default:
          return l10n.appName;
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(getTitle()),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: AppColors.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  const Icon(Icons.pets, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  Text(
                    widget.petName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard),
              title: Text(l10n.navDashboard),
              selected: _selectedIndex == 0,
              selectedColor: AppColors.primary,
              onTap: () => _onItemTapped(0),
            ),
            ListTile(
              leading: const Icon(Icons.map),
              title: Text(l10n.navZones),
              selected: _selectedIndex == 1,
              selectedColor: AppColors.primary,
              onTap: () => _onItemTapped(1),
            ),
            ListTile(
              leading: const Icon(Icons.medical_services),
              title: Text(l10n.navMedical),
              selected: _selectedIndex == 2,
              selectedColor: AppColors.primary,
              onTap: () => _onItemTapped(2),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(l10n.navSettings),
              selected: _selectedIndex == 3,
              selectedColor: AppColors.primary,
              onTap: () => _onItemTapped(3),
            ),
          ],
        ),
      ),
      body: _screens[_selectedIndex],
    );
  }
}
