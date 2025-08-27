// File: lib/services/api_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/screens/token_and_payment/buy_token.dart';
import 'package:snaprent/widgets/screen_guard.dart';
import '../screens/auth/login_screen.dart';

// Your base URL should be a constant.
const String _baseUrl = "http://192.168.8.103:3000/api/v1";

// Create a GlobalKey to access the navigator state from a non-widget class.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// The provider for ApiService. This allows us to access the authState.
final apiServiceProvider = Provider<ApiService>((ref) {
  // Pass the ProviderRef to the ApiService
  return ApiService(ref);
});

class ApiService {
  final ProviderRef _ref;

  ApiService(this._ref);

  Future<Map<String, String>> _getHeaders() async {
    final authState = _ref.read(authProvider).valueOrNull;
    final token = authState?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Handles 401 Unauthorized status.
  void _handleUnauthorized() {
    _ref.read(authProvider.notifier).logout();

    final context = navigatorKey.currentState?.context;
    if (context != null) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  /// Handles 403 Forbidden status.
  void _handleForbidden() {
    final context = navigatorKey.currentState?.context;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const ScreenGuard(screen: BuyTokenScreen()),
        ),
      );
    }
  }

  Future<dynamic> get(
    String endpoint, [
    Map<String, String>? queryParams,
  ]) async {
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);
    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> body) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response);
  }

  dynamic _handleResponse(http.Response response) {
    if (response.statusCode == 401) {
      _handleUnauthorized();
      throw Exception('Unauthorized');
    } else if (response.statusCode == 403) {
      _handleForbidden();
      throw Exception('Forbidden');
    } else if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(response.body);
      } catch (_) {
        throw Exception('Invalid JSON response');
      }
    } else {
      dynamic decoded;
      try {
        decoded = jsonDecode(response.body);
      } catch (_) {
        // If decoding fails, provide a generic error message
        throw Exception('Request failed with status ${response.statusCode}');
      }
      final errorMessage = decoded is Map && decoded.containsKey('message')
          ? decoded['message']
          : 'Request failed with status ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  /// This function can be used outside the ApiService for token refresh.
  static Future<Map<String, dynamic>> refreshTokenFn(
    String refreshToken,
  ) async {
    try {
      final url = Uri.parse('$_baseUrl/auth/refresh');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refreshToken': refreshToken}),
      );

      final res = jsonDecode(response.body);

      if (response.statusCode != 200 ||
          res == null ||
          res['success'] != true ||
          res['data']?['tokens'] == null) {
        throw Exception('Failed to refresh token');
      }
      return Map<String, dynamic>.from(res['data']['tokens']);
    } catch (e) {
      debugPrint('Error refreshing token: $e');
      rethrow; // Re-throw the error so the caller can handle it
    }
  }
}
