import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/models/auth_state.dart';

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<AuthState?>>(
      (ref) => throw UnimplementedError(), // Will be overridden in main
    );

class AuthNotifier extends StateNotifier<AsyncValue<AuthState?>> {
  final SharedPreferences _prefs;
  final Future<Map<String, dynamic>> Function(String refreshToken)
  _refreshTokenFn;
  static const _authKey = 'authState';

  AuthNotifier(this._prefs, this._refreshTokenFn)
    : super(const AsyncValue.data(null));

  Future<void> loadFromStorage() async {
    final authJson = _prefs.getString(_authKey);
    if (authJson == null) return;

    try {
      final authState = AuthState.fromJson(jsonDecode(authJson));
      state = AsyncValue.data(authState);
    } catch (e, stack) {
      debugPrint('Error loading auth state from storage: $e');
      debugPrintStack(stackTrace: stack);
      state = AsyncValue.error('Failed to load auth state', stack);
    }
  }

  Future<void> login(AuthState authState) async {
    state = AsyncValue.data(authState);
    await _prefs.setString(_authKey, jsonEncode(authState.toJson()));
  }

  Future<void> logout() async {
    state = const AsyncValue.data(null);
    await _prefs.remove(_authKey);
  }

  void resetState() {
    state = const AsyncValue.data(null);
  }

  Future<void> refreshIfNeeded() async {
    final authState = state.valueOrNull;

    if (authState == null || !authState.willExpireSoon) {
      return;
    }

    try {
      state = const AsyncValue.loading();
      final newTokens = await _refreshTokenFn(authState.refreshToken);
      final newAuthState = AuthState(
        accessToken: newTokens['accessToken'] as String,
        refreshToken: newTokens['refreshToken'] as String,
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
        userId: authState.userId,
      );
      state = AsyncValue.data(newAuthState);
      await _prefs.setString(_authKey, jsonEncode(newAuthState.toJson()));
      // debugPrint('Token refreshed successfully.');
    } catch (e, stack) {
      // debugPrint('Token refresh failed: $e');
      // debugPrintStack(stackTrace: stack);
      state = const AsyncValue.data(null);
    }
  }
}
