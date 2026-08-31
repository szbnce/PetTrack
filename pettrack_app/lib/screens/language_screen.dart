import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pettrack_app/main.dart';
import 'package:pettrack_app/screens/welcome_screen.dart';

class LanguageScreen extends StatelessWidget {
  const LanguageScreen({super.key});

  Future<void> _selectLanguage(BuildContext context, String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language_code', code);
    
    if (!context.mounted) return;
    
    PetTrackApp.setLocale(context, Locale(code));
    
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const WelcomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Choose Language\nVálassz nyelvet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 48),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildLangButton(context, 'hu', 'Magyar', colorScheme.primary, colorScheme.onPrimary),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'en', 'English', colorScheme.secondary, colorScheme.onSecondary),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'zh', '中文 (AI-GENERATED)', Colors.orange.shade700, Colors.white),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'it', 'Italiano (AI-GENERATED)', Colors.green.shade700, Colors.white),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'de', 'Deutsch (AI-GENERATED)', Colors.blue.shade700, Colors.white),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'ja', '日本語 (AI-GENERATED)', Colors.purple.shade700, Colors.white),
                      const SizedBox(height: 16),
                      _buildLangButton(context, 'ko', '한국어 (AI-GENERATED)', Colors.red.shade700, Colors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLangButton(BuildContext context, String code, String label, Color bg, Color fg) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 20),
          backgroundColor: bg,
          foregroundColor: fg,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: () => _selectLanguage(context, code),
        child: Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
    );
}
}
