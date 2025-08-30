import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/screens/auth/login_screen.dart';
import 'package:snaprent/screens/property_screens/add_property_screen.dart';
import 'package:snaprent/screens/user_screens/users_properties.dart';
import 'package:snaprent/screens/user_screens/privacy_policy_screen.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/services/screen_guard.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import 'package:snaprent/widgets/user_widgets/change_password_modal.dart';
import 'package:shimmer/shimmer.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  bool isUpdating = false;

  String? current;
  String? newPass;
  String? confirmPass;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool get hasChanges {
    final user = ref.watch(authProvider).value?.user;
    return nameController.text != user?.fullName ||
        phoneController.text != user?.phone;
  }

  Future<void> _updateUserInfo() async {
    if (!hasChanges) return;
    if (!mounted) return;
    setState(() => isUpdating = true);

    final phone = formatCameroonPhone(phoneController.text, context);
    final cameroonPhoneRegex = RegExp(r'^(?:\+237|237)?6\d{8}$');

    if (!cameroonPhoneRegex.hasMatch(phone)) {
      if (!mounted) return;
      setState(() => isUpdating = false);
      return;
    }

    try {
      final api = ref.read(apiServiceProvider);
      final data = await api.put('users', {
        'fullName': nameController.text,
        'phone': phone,
      }, context);

      if (!mounted) return;

      if (data['success'] == true) {
        // Corrected line: `data['data']` is already a Map
        ref.read(authProvider.notifier).updateUser(data['data']);
        setState(() {});
        SnackbarHelper.show(context, data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, 'Update failed', success: false);
    } finally {
      setState(() => isUpdating = false);
    }
  }

  void navigateToAddProperty() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const ScreenGuard(screen: AddPropertyScreen()),
      ),
    );
  }

  Widget _buildProfileItem({
    required String label,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text(label, style: const TextStyle(fontSize: 16)),
        trailing:
            trailing ??
            (onTap != null
                ? const Icon(Icons.arrow_forward_ios, size: 16)
                : null),
        onTap: onTap,
      ),
    );
  }

  Widget _buildEditableCard({
    required String label,
    required TextEditingController controller,
  }) {
    return Card(
      elevation: 2,
      shadowColor: Colors.grey.shade200,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: TextField(
          controller: controller,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            labelText: label,
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerProfile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: CircleAvatar(radius: 50, backgroundColor: Colors.grey[300]),
        ),
        const SizedBox(height: 16),
        _buildShimmerCard(),
        _buildShimmerCard(),
        _buildShimmerCard(),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(vertical: 8),
        child: const SizedBox(height: 60, width: double.infinity),
      ),
    );
  }

  void _showChangePasswordDrawer() async {
    final results = await showGeneralDialog(
      context: context,
      barrierLabel: "Change Password Drawer",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double screenWidth = MediaQuery.of(context).size.width;

        return Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: screenWidth,
              height: screenHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const ChangePasswordDrawer(),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        );
      },
    );

    if (results != null) {
      final changePasswordDetails = results as Map<String, dynamic>;

      setState(() {
        current = changePasswordDetails['current'];
        newPass = changePasswordDetails['newPass'];
        confirmPass = changePasswordDetails['confirmPass'];
      });
      _changePassword();
    }
  }

  Future<void> _changePassword() async {
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

    setState(() => isUpdating = true);

    try {
      final response = await ref.read(apiServiceProvider).put(
        'auth/change-password',
        {'currentPassword': current, 'newPassword': newPass},
        context,
      );

      if (response['success'] == true) {
        if (!mounted) return;
        SnackbarHelper.show(context, 'Password changed successfully');
        ref.read(authProvider.notifier).logout();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      } else {
        if (!mounted) return;
        SnackbarHelper.show(
          context,
          response?['message'] ?? 'Failed to change password',
          success: false,
        );
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, 'Error changing password', success: false);
    } finally {
      if (!mounted) return;
      setState(() => isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider).value?.user;

    if (user != null) {
      if (nameController.text.isEmpty) {
        nameController.text = user.fullName;
      }
      if (phoneController.text.isEmpty) {
        phoneController.text = user.phone;
      }
    }

    final isDataAvailable = user != null;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            width: MediaQuery.of(context).size.width,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: user?.image != null
                      ? NetworkImage(user!.image as String)
                      : const AssetImage('assets/test/profile_pic.jpg')
                            as ImageProvider,
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(75, 0, 0, 0),
                      Color.fromARGB(195, 0, 0, 0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
            initialChildSize: 0.65,
            minChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: !isDataAvailable
                      ? _buildShimmerProfile()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: user.image != null
                                  ? NetworkImage(user.image as String)
                                  : const AssetImage(
                                          'assets/test/profile_pic.jpg',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(height: 16),
                            const Row(
                              children: [
                                Text(
                                  "General",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _buildEditableCard(
                              label: "Full Name",
                              controller: nameController,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: Card(
                                elevation: 2,
                                shadowColor: Colors.grey.shade200,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Email",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        user.email,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            _buildEditableCard(
                              label: "Phone",
                              controller: phoneController,
                            ),
                            const SizedBox(height: 20),
                            if (hasChanges)
                              ElevatedButton(
                                onPressed: isUpdating ? null : _updateUserInfo,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: isUpdating
                                    ? const CircularProgressIndicator(
                                        color: Colors.white,
                                      )
                                    : const Text(
                                        "Update",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            const Row(
                              children: [
                                Text(
                                  "Properties",
                                  style: TextStyle(
                                    color: Colors.indigo,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            _buildProfileItem(
                              label: "My Properties",
                              trailing: const Icon(Icons.home),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ScreenGuard(
                                      screen: UsersPropertiesScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Privacy & Security",
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (user.provider != "google")
                              _buildProfileItem(
                                label: "Change Password",
                                onTap: () {
                                  _showChangePasswordDrawer();
                                },
                              ),
                            _buildProfileItem(
                              label: "Privacy Policy",
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ScreenGuard(
                                      screen: PrivacyPolicyScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 200),
                          ],
                        ),
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 70.0),
        child: FloatingActionButton(
          onPressed: navigateToAddProperty,
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
}
