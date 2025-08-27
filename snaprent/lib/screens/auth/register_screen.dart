import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/models/auth_state.dart';
import 'package:snaprent/models/user_state.dart';
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/providers/user_provider.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/btn_widgets/primary_btn.dart';
import 'package:snaprent/widgets/btn_widgets/tertiary_btn.dart';
import 'package:snaprent/widgets/snack_bar.dart';

import '../main_navigation.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final Widget? redirectTo;

  const RegisterScreen({super.key, this.redirectTo});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  // No longer needed to manually instantiate ApiService
  // late ApiService api;
  // @override
  // void initState() {
  //   super.initState();
  //   api = ApiService(ref);
  // }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!mounted) return;

    setState(() => _isLoading = true);

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      // Use ref.read to get the ApiService instance from the provider
      final api = ref.read(apiServiceProvider);

      final data = await api.post('auth/register', {
        'email': email,
        'password': password,
        'fullName': fullName,
      });

      final message = data['message'] ?? 'Registered successfully';
      if (mounted) SnackbarHelper.show(context, message);

      final tokens = data['data']?['tokens'];
      final userJson = data['data']?['user'];
      if (tokens == null || userJson == null) {
        throw Exception("Invalid register response from server");
      }

      final expiresIn = tokens['expiresIn']?.toString() ?? '15m';
      final expiresAt = parseExpiry(expiresIn);

      final userModel = User(
        fullName: userJson['fullName'],
        email: userJson['email'],
        phone: userJson['phone'],
        image: userJson['image'],
      );

      final authState = AuthState(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        expiresAt: expiresAt,
        userId: userJson["_id"],
      );

      await ref.read(authProvider.notifier).login(authState);
      ref.read(userProvider.notifier).setUser(userModel);

      if (!mounted) return;
      if (widget.redirectTo != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.redirectTo!),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.show(context, "Registration failed: $e", success: false);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final GoogleSignIn signIn = GoogleSignIn.instance;
      await signIn.initialize(
        serverClientId:
            "558559280202-7u1fvv9gcdvaqbadtn5rpdp7gbm5dde9.apps.googleusercontent.com",
      );

      final GoogleSignInAccount? googleUser = await signIn.authenticate();

      if (googleUser == null) {
        SnackbarHelper.show(context, "Sign in cancelled", success: false);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken == null) throw Exception("Google ID token not available");

      // Use ref.read to get the ApiService instance from the provider
      final api = ref.read(apiServiceProvider);

      final data = await api.post('auth/google', {
        'email': googleUser.email,
        'idToken': idToken,
      });

      final message = data['message'] ?? 'Login successful';
      if (mounted) SnackbarHelper.show(context, message, success: true);

      final tokens = data['data']?['tokens'];
      final userJson = data['data']?['user'];
      if (tokens == null || userJson == null) {
        throw Exception("Invalid login response");
      }

      final expiresIn = tokens['expiresIn']?.toString() ?? '1h';
      DateTime expiresAt;
      if (expiresIn.endsWith('h')) {
        final hours = int.tryParse(expiresIn.replaceAll('h', '')) ?? 1;
        expiresAt = DateTime.now().add(Duration(hours: hours));
      } else {
        expiresAt = DateTime.now().add(Duration(hours: 1));
      }

      final userModel = User(
        fullName: userJson['fullName'],
        email: userJson['email'],
        phone: userJson['phone'],
        image: userJson['image'],
      );

      final authState = AuthState(
        accessToken: tokens['accessToken'],
        refreshToken: tokens['refreshToken'],
        expiresAt: expiresAt,
        userId: userJson["_id"],
      );

      await ref.read(authProvider.notifier).login(authState);
      ref.read(userProvider.notifier).setUser(userModel);

      if (!mounted) return;
      if (widget.redirectTo != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.redirectTo!),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainNavigation()),
        );
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.show(
          context,
          "Google Sign-In failed: $e",
          success: false,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    Color borderColor = Colors.grey,
    Color focusedBorderColor = Colors.indigo,
  }) {
    const borderRadius = 12.0;
    const iconColor = Colors.indigo;

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: iconColor),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Stack(
        children: [
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Image.asset(
                      'assets/lock_logo.png',
                      width: 200,
                      height: 150,
                      fit: BoxFit.contain,
                    ),
                    const Text(
                      "Create Account",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter email';
                        }
                        if (!value.contains('@')) return 'Invalid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildTextField(
                      controller: _fullNameController,
                      label: "Full Name",
                      icon: Icons.account_balance_sharp,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Enter full name';
                        }
                        if (!RegExp(r"^[a-zA-Z '-]+$").hasMatch(value.trim())) {
                          return 'Invalid name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      controller: _passwordController,
                      label: "Password",
                      icon: Icons.lock,
                      obscure: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter password';
                        }
                        if (value.length < 6) return 'Minimum 6 characters';
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    PrimaryBtn(
                      text: 'Register',
                      onPressed: () {
                        _register();
                      },
                    ),

                    const SizedBox(height: 16),
                    const Text("or"),
                    const SizedBox(height: 16),
                    TertiaryBtn(
                      text: "Continue with Google",
                      icon: Image.asset('assets/google_icon.png', height: 20),
                      onPressed: () {
                        _handleGoogleSignIn();
                      },
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                LoginScreen(redirectTo: widget.redirectTo),
                          ),
                        );
                      },
                      child: const Text("Already have an account? Login"),
                    ),
                    const SizedBox(height: 110),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
