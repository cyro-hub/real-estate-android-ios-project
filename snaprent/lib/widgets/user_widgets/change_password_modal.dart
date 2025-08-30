import 'package:flutter/material.dart';
import 'package:snaprent/widgets/btn_widgets/secondary_btn.dart';

class ChangePasswordDrawer extends StatefulWidget {
  final String? currentPassword;
  final String? newPassword;
  final String? confirmPassword;

  const ChangePasswordDrawer({
    super.key,
    this.currentPassword,
    this.newPassword,
    this.confirmPassword,
  });

  @override
  State<ChangePasswordDrawer> createState() => _ChangePasswordDrawerState();
}

class _ChangePasswordDrawerState extends State<ChangePasswordDrawer> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController currentController = TextEditingController();
  final TextEditingController newController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool isLoading = false;

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // late String? _currentPassword;
  // late String? _newPassword;
  // late String? _confirmPassword;

  @override
  void initState() {
    super.initState();
    // _currentPassword = widget.currentPassword;
    // _newPassword = widget.newPassword;
    // _confirmPassword = widget.confirmPassword;
  }

  @override
  void dispose() {
    currentController.dispose();
    newController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    Navigator.of(context).pop({
      'current': currentController.text.trim(),
      'newPass': newController.text.trim(),
      'confirmPass': confirmController.text.trim(),
    });
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    String? Function(String?)? validator,
    VoidCallback? onSuffixIconPressed,
    IconData? suffixIcon,
  }) {
    const borderRadius = 12.0;
    const iconColor = Colors.indigo;
    const borderColor = Colors.grey;
    const focusedBorderColor = Colors.indigo;

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
        suffixIcon: suffixIcon != null
            ? IconButton(
                icon: Icon(suffixIcon, color: iconColor),
                onPressed: onSuffixIconPressed,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: const BorderSide(color: focusedBorderColor, width: 2),
        ),
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(0),
          topRight: Radius.circular(0),
        ),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Change Password",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black54),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                  controller: currentController,
                  label: "Current Password",
                  icon: Icons.lock,
                  obscureText: !_isCurrentPasswordVisible,
                  suffixIcon: _isCurrentPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your current password.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: newController,
                  label: "New Password",
                  icon: Icons.lock_open,
                  obscureText: !_isNewPasswordVisible,
                  suffixIcon: _isNewPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _isNewPasswordVisible = !_isNewPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 6) {
                      return 'Password must be at least 6 characters long.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: confirmController,
                  label: "Confirm New Password",
                  icon: Icons.lock_outline,
                  obscureText: !_isConfirmPasswordVisible,
                  suffixIcon: _isConfirmPasswordVisible
                      ? Icons.visibility
                      : Icons.visibility_off,
                  onSuffixIconPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                  validator: (value) {
                    if (value != newController.text) {
                      return 'Passwords do not match.';
                    }
                    return null;
                  },
                ),
              ],
            ),
            const SizedBox(height: 52),
            SizedBox(
              child: ElevatedButton(
                onPressed: isLoading
                    ? null
                    : () {
                        if (_formKey.currentState!.validate()) {
                          _applyFilters();
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  padding: const EdgeInsets.symmetric(vertical: 16),
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              child: SecondaryButton(
                onPressed: () => Navigator.pop(context),
                text: "Cancel",
              ),
            ),
          ],
        ),
      ),
    );
  }
}
