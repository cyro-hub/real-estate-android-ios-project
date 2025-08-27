import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/screens/auth/login_screen.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/snack_bar.dart';

Future<void> showChangePasswordDialog(
  BuildContext context,
  WidgetRef ref,
) async {
  final api = ref.read(apiServiceProvider);

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;

  Future<void> _changePassword(StateSetter setState) async {
    final current = currentController.text.trim();
    final newPass = newController.text.trim();
    final confirmPass = confirmController.text.trim();

    if (current.isEmpty || newPass.isEmpty || confirmPass.isEmpty) {
      if (!context.mounted) return;
      SnackbarHelper.show(context, 'Please fill all fields', success: false);
      return;
    }

    if (newPass != confirmPass) {
      if (!context.mounted) return;
      SnackbarHelper.show(context, 'Passwords do not match', success: false);
      return;
    }

    if (newPass == current) {
      if (!context.mounted) return;
      SnackbarHelper.show(
        context,
        'Current password cannot be the same as new password',
        success: false,
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await api.put('auth/change-password', {
        'currentPassword': current,
        'newPassword': newPass,
      });

      if (!context.mounted) return;

      if (response['success'] == true) {
        SnackbarHelper.show(context, 'Password changed successfully');

        // Clear ONLY auth data
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('accessToken');
        await prefs.remove('refreshToken');
        await prefs.remove('expiresAt');
        await prefs.remove('userId');

        // Reset Riverpod state to an unauthenticated state
        ref.read(authProvider.notifier).resetState();

        // Close the modal
        Navigator.of(context).pop();

        // Navigate to login screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        SnackbarHelper.show(
          context,
          response?['message'] ?? 'Failed to change password',
          success: false,
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      SnackbarHelper.show(context, 'Error changing password', success: false);
    } finally {
      setState(() => isLoading = false);
    }
  }

  await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text("Change Password"),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Current Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "New Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Confirm New Password",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        setState(() => isLoading = true);
                        _changePassword(setState);
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Change",
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ],
          );
        },
      );
    },
  );
}
