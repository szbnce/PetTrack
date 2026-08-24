import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pettrack_app/l10n/app_localizations.dart';
import '../theme/colors.dart';
import 'dashboard_screen.dart';
import 'zones_screen.dart';
import 'settings_screen.dart';
import 'medical_screen.dart';
import 'replays_screen.dart';
import 'welcome_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _screens = [
      DashboardScreen(
        serverIp: widget.serverIp,
        token: widget.token,
        petName: widget.petName,
      ),
      ZonesScreen(serverIp: widget.serverIp, token: widget.token),
      MedicalScreen(serverIp: widget.serverIp, token: widget.token),
      ReplaysScreen(serverIp: widget.serverIp, token: widget.token),
      const SettingsScreen(),
    ];
  }

  void _onItemTapped(int index, {bool closeDrawer = false}) {
    setState(() {
      _selectedIndex = index;
    });
    if (closeDrawer && Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  Widget _buildSidebar(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Container(
      width: 250,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo Area
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Icon(Icons.pets, color: theme.colorScheme.primary, size: 32),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.appName,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Navigation Items
          _buildSidebarItem(
            context: context,
            icon: Icons.dashboard_outlined,
            activeIcon: Icons.dashboard,
            label: l10n.navDashboard,
            index: 0,
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.map_outlined,
            activeIcon: Icons.map,
            label: l10n.navZones,
            index: 1,
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services,
            label: l10n.navMedical,
            index: 2,
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.history_outlined,
            activeIcon: Icons.history,
            label: "Replays",
            index: 3,
          ),
          _buildSidebarItem(
            context: context,
            icon: Icons.settings_outlined,
            activeIcon: Icons.settings,
            label: l10n.navSettings,
            index: 4,
          ),
          const Spacer(),
          // Logout Button
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () async {
                final prefs = await SharedPreferences.getInstance();
                await prefs.remove('server_ip');
                await prefs.remove('secret_token');
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const WelcomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(Icons.logout, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    const SizedBox(width: 12),
                    Text(
                      "Log Out",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem({
    required BuildContext context,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
  }) {
    final theme = Theme.of(context);
    final isActive = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _onItemTapped(index),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isActive ? theme.colorScheme.primary : Colors.transparent,
          ),
          padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
          child: Row(
            children: [
              Icon(
                isActive ? activeIcon : icon,
                color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              const SizedBox(width: 16),
              Text(
                label,
                style: TextStyle(
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    String getTitle() {
      switch (_selectedIndex) {
        case 0: return l10n.appName;
        case 1: return l10n.navZones;
        case 2: return l10n.navMedical;
        case 3: return "Replays";
        case 4: return l10n.navSettings;
        default: return l10n.appName;
      }
    }

    final List<NavigationDestination> destinations = [
      NavigationDestination(icon: const Icon(Icons.dashboard), label: l10n.navDashboard),
      NavigationDestination(icon: const Icon(Icons.map), label: l10n.navZones),
      NavigationDestination(icon: const Icon(Icons.medical_services), label: l10n.navMedical),
      NavigationDestination(icon: const Icon(Icons.history), label: "Replays"),
      NavigationDestination(icon: const Icon(Icons.settings), label: l10n.navSettings),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: MediaQuery.of(context).size.width < 800
          ? AppBar(
              title: Text(getTitle()),
              elevation: 0,
              backgroundColor: Colors.transparent,
            )
          : null, // No AppBar on desktop, we have sidebar + custom headers
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= 800) {
            // Wide screen: Custom Sidebar
            return Row(
              children: [
                _buildSidebar(context, l10n),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: _screens[_selectedIndex]),
              ],
            );
          } else {
            // Narrow screen: BottomNavigationBar
            return _screens[_selectedIndex];
          }
        },
      ),
      bottomNavigationBar: MediaQuery.of(context).size.width < 800
          ? NavigationBar(
              selectedIndex: _selectedIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx),
              destinations: destinations,
            )
          : null,
    );
  }
}
