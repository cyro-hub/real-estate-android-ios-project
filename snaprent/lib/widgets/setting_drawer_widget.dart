import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/providers/language_provider.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import '../../providers/auth_provider.dart';

// A function to show the settings drawer as a right-side sliding sheet
void showSettingsDrawer(BuildContext context, WidgetRef ref) {
  showGeneralDialog(
    context: context,
    barrierLabel: "Settings Drawer",
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.4), // Darker overlay
    transitionDuration: const Duration(milliseconds: 300), // Animation duration
    pageBuilder: (_, __, ___) {
      return Align(
        alignment: Alignment.centerRight,
        child: Material(
          type:
              MaterialType.transparency, // Allows the container's shape to show
          child: Container(
            // Set the drawer's width to a maximum of 70% of the screen
            width: MediaQuery.of(context).size.width * 0.70,
            // Height adjusted to touch top and have 100px from bottom
            height: MediaQuery.of(context).size.height,
            // Align to top, add bottom margin
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0), // Updated border radius
                bottomLeft: Radius.circular(0), // Updated border radius
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const SettingDrawer(),
          ),
        ),
      );
    },
    transitionBuilder: (_, animation, __, child) {
      return SlideTransition(
        position: Tween(
          begin: const Offset(1, 0), // Start from off-screen right
          end: Offset.zero, // End at its normal position
        ).animate(animation),
        child: child,
      );
    },
  );
}

class SettingDrawer extends ConsumerStatefulWidget {
  const SettingDrawer({super.key});

  @override
  ConsumerState<SettingDrawer> createState() => _SettingDrawerState();
}

class _SettingDrawerState extends ConsumerState<SettingDrawer> {
  bool notificationsEnabled = true;
  bool darkMode = false;

  final Map<String, String> languageMap = {"en": "English", "fr": "French"};

  Widget _buildSettingItem({
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
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
    Navigator.of(context).pop(); // Close the drawer after logout
  }

  @override
  Widget build(BuildContext context) {
    // Get the current locale from the provider
    final currentLocale = ref.watch(languageProvider);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(""),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.black87),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      "General",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    _buildSettingItem(
                      label: "Enable Notifications",
                      trailing: Transform.scale(
                        scale: .60,
                        child: Switch(
                          value: notificationsEnabled,
                          onChanged: (val) =>
                              setState(() => notificationsEnabled = val),
                          activeColor: Colors.indigo,
                          inactiveTrackColor: Colors.white,
                          inactiveThumbColor: Colors.indigo,
                          trackOutlineColor: MaterialStateProperty.all(
                            const Color.fromARGB(177, 63, 81, 181),
                          ),
                        ),
                      ),
                    ),
                    _buildSettingItem(
                      label: "Dark Mode",
                      trailing: Transform.scale(
                        scale: .60,
                        child: Switch(
                          value: darkMode,
                          onChanged: (val) => setState(() => darkMode = val),
                          activeColor: Colors.indigo,
                          inactiveTrackColor: Colors.white,
                          inactiveThumbColor: Colors.indigo,
                          trackOutlineColor: MaterialStateProperty.all(
                            const Color.fromARGB(177, 63, 81, 181),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      "Language",
                      style: TextStyle(
                        color: Colors.indigo,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: DropdownButtonFormField<String>(
                        value: languageMap[currentLocale.languageCode],
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                        ),
                        style: const TextStyle(color: Colors.black87),
                        items: languageMap.values
                            .map(
                              (lang) => DropdownMenuItem(
                                value: lang,
                                child: Text(lang),
                              ),
                            )
                            .toList(),
                        onChanged: (val) async {
                          if (val != null) {
                            final newLanguageCode = languageMap.entries
                                .firstWhere((entry) => entry.value == val)
                                .key;

                            await ref
                                .read(languageProvider.notifier)
                                .setLanguage(newLanguageCode);

                            SnackbarHelper.show(
                              context,
                              'Language changed to $val',
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          Positioned(
            bottom: 60,
            right: 8,
            child: GestureDetector(
              onTap: () {
                _logout();
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Logout",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.deepOrange,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.power_settings_new, // shutdown logo
                    color: Colors.deepOrange,
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
