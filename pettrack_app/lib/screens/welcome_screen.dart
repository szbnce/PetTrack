import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pettrack_app/l10n/app_localizations.dart';
import 'package:pettrack_app/screens/setup_wizard_screen.dart';
import 'package:pettrack_app/screens/monitor_setup_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  Future<void> _selectMode(BuildContext context, String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_mode', mode);

    if (!context.mounted) return;

    if (mode == 'client') {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SetupWizardScreen()),
      );
    } else {
      // Monitor mode
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MonitorSetupScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.welcomeTitle),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.chooseMode,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: colorScheme.primary,
                  foregroundColor: colorScheme.onPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _selectMode(context, 'client'),
                child: Column(
                  children: [
                    const Icon(Icons.monitor, size: 48),
                    const SizedBox(height: 8),
                    Text(l10n.modeClient, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(l10n.modeClientDesc, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  backgroundColor: colorScheme.secondary,
                  foregroundColor: colorScheme.onSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () => _selectMode(context, 'monitor'),
                child: Column(
                  children: [
                    const Icon(Icons.videocam, size: 48),
                    const SizedBox(height: 8),
                    Text(l10n.modeMonitor, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(l10n.modeMonitorDesc, style: const TextStyle(fontSize: 14)),
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
