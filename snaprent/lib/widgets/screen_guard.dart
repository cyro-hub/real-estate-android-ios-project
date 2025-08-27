import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// A widget that protects a screen from unauthenticated users.
/// It displays a loading screen while authentication is checked,
/// and redirects to the login screen if the user is not authenticated.
class ScreenGuard extends ConsumerWidget {
  final Widget screen;

  const ScreenGuard({super.key, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch the AsyncValue state of the authProvider
    final authState = ref.watch(authProvider);

    // Listen to changes in the authentication state
    ref.listen<AsyncValue<AuthState?>>(authProvider, (previous, next) {
      // final previousState = previous?.valueOrNull;
      final nextState = next.valueOrNull;

      // Check if a token is present and will expire soon to trigger a refresh.
      if (nextState != null && nextState.willExpireSoon) {
        // Use a future to avoid rebuilds during refresh
        Future.microtask(
          () => ref.read(authProvider.notifier).refreshIfNeeded(),
        );
      }
    });

    // Handle different AsyncValue states
    return switch (authState) {
      // Show a loading indicator while the state is being initialized (e.g., from storage)
      AsyncValue(:final isLoading) when isLoading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      // Data is null, meaning no user is authenticated. Show the login screen.
      AsyncData(value: null) => LoginScreen(redirectTo: screen),

      // Data is not null, meaning a user is authenticated. Show the protected screen.
      AsyncData(value: final auth) when auth != null => screen,

      // An error occurred during initial loading. Show an error screen.
      AsyncError(:final error, :final stackTrace) => Scaffold(
        body: Center(
          child: Text(
            'Auth Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      _ => const SizedBox.shrink(), // Fallback for other states
    };
  }
}
