import 'package:flutter/material.dart';

Widget textField({
  required TextEditingController controller,
  required String label,
  IconData? icon,
  bool obscure = false,
  Widget? suffixIcon,
  String? Function(String?)? validator,
  int maxLines = 1,
  TextInputType keyboardType = TextInputType.text, // added keyboardType
  Color borderColor = Colors.grey,
  Color focusedBorderColor = Colors.indigo,
}) {
  const borderRadius = 12.0;
  const iconColor = Colors.indigo;

  return TextFormField(
    controller: controller,
    obscureText: obscure,
    maxLines: maxLines,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, color: iconColor) : null,
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
    ),
    validator: validator,
  );
}

Widget dropdownField({
  required String? value,
  required String label,
  required List<DropdownMenuItem<String>> items,
  required void Function(String?) onChanged,
  String? Function(String?)? validator,
  Color borderColor = Colors.grey,
  Color focusedBorderColor = Colors.indigo,
}) {
  const borderRadius = 12.0;

  return DropdownButtonFormField<String>(
    value: value,
    items: items,
    onChanged: onChanged,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(color: focusedBorderColor, width: 2),
      ),
    ),
  );
}
