import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/models/auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState?>>(
      (ref) => throw UnimplementedError(),
    );

class AuthNotifier extends StateNotifier<AsyncValue<AuthState?>> {
  final SharedPreferences _prefs;
  final Future<Map<String, dynamic>> Function(String refreshToken)
  _refreshTokenFn;
  static const _authKey = 'authState';

  AuthNotifier(this._prefs, this._refreshTokenFn)
    : super(const AsyncValue.data(null));

  /// Loads the authentication state from local storage.
  Future<void> loadFromStorage() async {
    final authJson = _prefs.getString(_authKey);
    if (authJson == null) {
      state = const AsyncValue.data(null);
      return;
    }

    try {
      final authState = AuthState.fromJson(jsonDecode(authJson));
      state = AsyncValue.data(authState);
    } catch (e, stack) {
      debugPrint('Error loading auth state from storage: $e');
      debugPrintStack(stackTrace: stack);
      state = AsyncValue.error('Failed to load auth state', stack);
    }
  }

  /// Handles the login process and updates the state.
  Future<void> login(AuthState authState) async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(authState);
      await _prefs.setString(_authKey, jsonEncode(authState.toJson()));
    } catch (e, stack) {
      state = AsyncValue.error('Failed to login', stack);
    }
  }

  /// Handles the logout process.
  Future<void> logout() async {
    state = const AsyncValue.data(null);
    await _prefs.remove(_authKey);
  }

  /// Resets the state.
  void resetState() {
    state = const AsyncValue.data(null);
  }

  /// Refreshes the access token if it's close to expiring.
  Future<void> refreshIfNeeded() async {
    final authState = state.valueOrNull;

    if (authState == null || !authState.willExpireSoon) {
      return;
    }

    try {
      state = AsyncValue.data(authState); // Return to a data state
      print('Refreshing token... $state');
      final newTokens = await _refreshTokenFn(authState.refreshToken);
      final newAuthState = authState.copyWith(
        accessToken: newTokens['accessToken'] as String,
        refreshToken: newTokens['refreshToken'] as String,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );
      state = AsyncValue.data(newAuthState);
      await _prefs.setString(_authKey, jsonEncode(newAuthState.toJson()));
    } catch (e, stack) {
      state = AsyncValue.error('Failed to refresh token', stack);
      await logout();
    }
  }

  /// Updates the user information in the current state and saves it.
  Future<void> updateUser(Map<String, dynamic> userData) async {
    final authState = state.valueOrNull;
    if (authState == null) {
      return;
    }

    try {
      final updatedUser = User.fromJson(userData);
      final updatedAuthState = authState.copyWith(user: updatedUser);
      state = AsyncValue.data(updatedAuthState);
      await _prefs.setString(_authKey, jsonEncode(updatedAuthState.toJson()));
    } catch (e, stack) {
      debugPrint('Error updating user state: $e');
      debugPrintStack(stackTrace: stack);
      // You might not want to show a snackbar here as the calling widget handles it,
      // but it's good for debugging.
    }
  }
}
