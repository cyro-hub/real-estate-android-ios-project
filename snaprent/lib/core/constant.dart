import 'package:flutter/material.dart';
import 'package:snaprent/widgets/snack_bar.dart';

String formatPrice(num price) {
  if (price >= 1000000) {
    return '${(price / 1000000).toStringAsFixed((price % 1000000 == 0) ? 0 : 2)}mil';
  } else if (price >= 1000) {
    return '${(price / 1000).toStringAsFixed((price % 1000 == 0) ? 0 : 2)}k';
  } else {
    return price.toString();
  }
}

String shorten(String text, {int maxLength = 100}) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength)}...';
}

String capitalizeFirstLetter(String? text) {
  if (text == null || text.isEmpty) return '';
  return '${text[0].toUpperCase()}${text.substring(1)}';
}

String formatCameroonPhone(String phone, BuildContext context) {
  // Remove all non-digit characters
  String digits = phone.replaceAll(RegExp(r'\D'), '');

  // Remove leading 237 if present
  if (digits.startsWith('237')) {
    digits = digits.substring(3);
  }

  // Must start with 6 and be 9 digits long
  if (digits.length != 9 || !digits.startsWith('6')) {
    SnackbarHelper.show(context, "Invalid number", success: false);

    return 'Invalid number';
  }

  // Format: +237 6XX XXX XXX
  String formatted =
      '+237${digits.substring(0, 3)}${digits.substring(3, 6)}${digits.substring(6, 9)}';

  return formatted;
}

DateTime parseExpiry(String expiresIn) {
  final now = DateTime.now();

  if (expiresIn.endsWith('m')) {
    final minutes = int.tryParse(expiresIn.replaceAll('m', '')) ?? 15;
    return now.add(Duration(minutes: minutes));
  } else if (expiresIn.endsWith('h')) {
    final hours = int.tryParse(expiresIn.replaceAll('h', '')) ?? 1;
    return now.add(Duration(hours: hours));
  } else if (expiresIn.endsWith('d')) {
    final days = int.tryParse(expiresIn.replaceAll('d', '')) ?? 7;
    return now.add(Duration(days: days));
  }

  // Default to 15 minutes if format unknown
  return now.add(const Duration(minutes: 15));
}
