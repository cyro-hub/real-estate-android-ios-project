import 'package:flutter/material.dart';

class SnackbarHelper {
  // Show a custom snackbar
  static void show(
    BuildContext context,
    String message, {
    bool success = true,
    Duration duration = const Duration(seconds: 3),
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: success ? Colors.green : Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: duration,
      ),
    );
  }
}
