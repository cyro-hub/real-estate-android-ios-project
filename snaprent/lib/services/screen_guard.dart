import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/auth_state.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

class ScreenGuard extends ConsumerWidget {
  final Widget screen;

  const ScreenGuard({super.key, required this.screen});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    ref.listen<AsyncValue<AuthState?>>(authProvider, (previous, next) {
      final nextState = next.valueOrNull;

      if (nextState != null && nextState.willExpireSoon) {
        Future.microtask(
          () => ref.read(authProvider.notifier).refreshIfNeeded(),
        );
      }
    });

    return switch (authState) {
      AsyncValue(:final isLoading) when isLoading => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),

      AsyncData(value: null) => LoginScreen(redirectTo: screen),

      AsyncData(value: final auth) when auth != null => screen,

      AsyncError(:final error) => Scaffold(
        body: Center(
          child: Text(
            'Auth Error: $error',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),

      _ => const SizedBox.shrink(),
    };
  }
}
