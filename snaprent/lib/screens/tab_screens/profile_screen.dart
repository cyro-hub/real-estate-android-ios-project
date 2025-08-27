import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/screens/property_screens/add_property_screen.dart';
import 'package:snaprent/screens/user_screens/users_properties.dart';
import 'package:snaprent/screens/user_screens/privacy_policy_screen.dart';
import 'package:snaprent/screens/user_screens/settings_screen.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/screen_guard.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import 'package:snaprent/widgets/user_widgets/change_password_modal.dart';
import 'package:shimmer/shimmer.dart'; // Add shimmer for loading state

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Map<String, dynamic>? userInfo;
  bool isLoading = true;
  bool isUpdating = false;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;

  // No manual instantiation of ApiService here

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    phoneController = TextEditingController();
    _fetchUserInfo();
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _fetchUserInfo() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    try {
      // Use ref.read() to get the ApiService instance
      final api = ref.read(apiServiceProvider);
      final data = await api.get('users');

      if (!mounted) return;
      if (data != null && data['data'] != null) {
        userInfo = Map<String, dynamic>.from(data['data']);
        nameController.text = userInfo!['fullName'] ?? '';
        phoneController.text = userInfo!['phone'] ?? '+237 --- --- ---';
      }
    } catch (e) {
      debugPrint('Error fetching user info: $e');
    } finally {
      if (!mounted) return;
      setState(() => isLoading = false);
    }
  }

  bool get hasChanges {
    if (userInfo == null) return false;
    return nameController.text != userInfo!['fullName'] ||
        phoneController.text != userInfo!['phone'];
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
      final data = await api.put(
        'users', // replace with your endpoint
        {'fullName': nameController.text, 'phone': phone},
      );

      if (!mounted) return;

      if (data['success'] == true) {
        userInfo = data['data'];
        nameController.text = userInfo!['fullName'] ?? '';
        phoneController.text = userInfo!['phone'] ?? '+237 --- --- ---';
        setState(() {});
        SnackbarHelper.show(context, data['message']);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(context, 'Update failed', success: false);
    } finally {
      if (!mounted) return;
      setState(() => isUpdating = false);
    }
  }

  void navigateToAddProperty() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ScreenGuard(screen: AddPropertyScreen()),
      ),
    );
  }

  void navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ScreenGuard(screen: SettingScreen())),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.indigo.shade700, Colors.indigo.shade400],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Settings icon
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            right: 16,
            child: IconButton(
              onPressed: navigateToSettings,
              icon: const Icon(Icons.settings, color: Colors.white, size: 28),
            ),
          ),

          // Draggable Sheet
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
                  child: isLoading
                      ? _buildShimmerProfile()
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 50,
                              backgroundImage: userInfo?['image'] != null
                                  ? NetworkImage(userInfo!['image'] as String)
                                  : const AssetImage(
                                          'assets/test/profile_pic.jpg',
                                        )
                                        as ImageProvider,
                            ),
                            const SizedBox(height: 16),

                            // Editable fields
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
                                        userInfo?['email'] ?? '',
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
                            const SizedBox(height: 30),

                            // My Properties
                            _buildProfileItem(
                              label: "My Properties",
                              trailing: const Icon(Icons.home),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ScreenGuard(
                                      screen: UsersPropertiesScreen(),
                                    ),
                                  ),
                                );
                              },
                            ),

                            // Privacy Section
                            const SizedBox(height: 20),
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Privacy & Security",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (userInfo?['provider'] != "google")
                              _buildProfileItem(
                                label: "Change Password",
                                onTap: () {
                                  showChangePasswordDialog(context, ref);
                                },
                              ),
                            _buildProfileItem(
                              label: "Privacy Policy",
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ScreenGuard(
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
