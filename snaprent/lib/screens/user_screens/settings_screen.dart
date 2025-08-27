import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/l10n/app_localizations.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import '../../widgets/safe_scaffold.dart';
import '../../providers/auth_provider.dart';
import 'package:restart_app/restart_app.dart';

// --- Language provider ---
final languageProvider = StateNotifierProvider<LanguageNotifier, String>((ref) {
  return LanguageNotifier();
});

class LanguageNotifier extends StateNotifier<String> {
  LanguageNotifier() : super('en') {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString('language') ?? 'en';
  }

  Future<void> setLanguage(String langCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', langCode);
    state = langCode;
  }
}

// --- SettingScreen ---
class SettingScreen extends ConsumerStatefulWidget {
  const SettingScreen({super.key});

  @override
  ConsumerState<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends ConsumerState<SettingScreen> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  final List<String> languages = ["English", "French"];

  Widget _buildSettingItem({
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
          if (trailing != null) trailing,
          if (onTap != null)
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios, size: 16),
              onPressed: onTap,
            ),
        ],
      ),
    );
  }

  void _logout() {
    ref.read(authProvider.notifier).logout();
    SnackbarHelper.show(context, "Logged out successfully.");
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(
              AppLocalizations.of(context)!.settings,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            const Text("General", style: TextStyle(color: Colors.grey)),
            _buildSettingItem(
              label: "Enable Notifications",
              trailing: Switch(
                value: notificationsEnabled,
                onChanged: (val) => setState(() => notificationsEnabled = val),
              ),
            ),
            _buildSettingItem(
              label: "Dark Mode",
              trailing: Switch(
                value: darkMode,
                onChanged: (val) => setState(() => darkMode = val),
              ),
            ),

            const SizedBox(height: 20),

            const Text("Language", style: TextStyle(color: Colors.grey)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: DropdownButtonFormField<String>(
                value: ref.watch(languageProvider) == 'en'
                    ? "English"
                    : "French",
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                items: ["English", "French"]
                    .map(
                      (lang) =>
                          DropdownMenuItem(value: lang, child: Text(lang)),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    ref
                        .read(languageProvider.notifier)
                        .setLanguage(val == "English" ? 'en' : 'fr');

                    SnackbarHelper.show(context, 'Language changed to $val');

                    Restart.restartApp(
                      notificationTitle: 'Restarting App',
                      notificationBody:
                          'Please tap here to open the app again.',
                    );
                  }
                },
              ),
            ),

            const SizedBox(height: 40),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 63, 81, 181),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings saved')),
                  );
                },
                child: const Text(
                  "Save Settings",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _logout,
                child: const Text(
                  "Logout",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
