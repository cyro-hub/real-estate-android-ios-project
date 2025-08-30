import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:snaprent/providers/auth_provider.dart';
import 'package:snaprent/screens/token_and_payment/buy_token.dart';
import 'package:snaprent/services/screen_guard.dart';
import '../screens/auth/login_screen.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

const String _baseUrl = "http://192.168.8.103:3000/api/v1";

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(ref);
});

class ApiService {
  final Ref _ref;

  ApiService(this._ref);

  Future<Map<String, String>> _getHeaders() async {
    final authState = _ref.read(authProvider).valueOrNull;
    final token = authState?.accessToken ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(
    String endpoint, [
    Map<String, String>? queryParams,
    BuildContext? context,
  ]) async {
    await checkConnectivityAndMakeApiCall();
    final headers = await _getHeaders();
    final uri = Uri.parse(
      '$_baseUrl/$endpoint',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    return _handleResponse(response, context: context);
  }

  Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> body,
    BuildContext? context,
  ) async {
    await checkConnectivityAndMakeApiCall();
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    return _handleResponse(response, context: context);
  }

  Future<dynamic> put(
    String endpoint,
    Map<String, dynamic> body,
    BuildContext? context,
  ) async {
    await checkConnectivityAndMakeApiCall();
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );
    print('PUT $endpoint: ${response.statusCode} ${response.body}');
    return _handleResponse(response, context: context);
  }

  Future<dynamic> delete(String endpoint, BuildContext? context) async {
    await checkConnectivityAndMakeApiCall();
    final headers = await _getHeaders();
    final uri = Uri.parse('$_baseUrl/$endpoint');
    final response = await http.delete(uri, headers: headers);
    return _handleResponse(response, context: context);
  }

  dynamic _handleResponse(http.Response response, {BuildContext? context}) {
    if (response.statusCode == 401) {
      _ref.read(authProvider.notifier).logout();

      if (context != null) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (Route<dynamic> route) =>
              false, // This condition removes all previous routes
        );
      }
      return Future.error(Exception('Unauthorized'));
    } else if (response.statusCode == 403) {
      if (context != null) {
        // Use push to navigate to BuyTokenScreen, as it's a temporary screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => const ScreenGuard(screen: BuyTokenScreen()),
          ),
        );
      }
      return Future.error(Exception('Forbidden'));
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
        throw Exception('Request failed with status ${response.statusCode}');
      }
      final errorMessage = decoded is Map && decoded.containsKey('message')
          ? decoded['message']
          : 'Request failed with status ${response.statusCode}';
      throw Exception(errorMessage);
    }
  }

  static Future<void> checkConnectivityAndMakeApiCall() async {
    var connectivityResult = await (Connectivity().checkConnectivity());

    if (!connectivityResult.contains(ConnectivityResult.mobile) &&
        !connectivityResult.contains(ConnectivityResult.wifi) &&
        !connectivityResult.contains(ConnectivityResult.ethernet)) {
      return Future.error(Exception('No internet connectivity'));
    }
  }

  static Future<Map<String, dynamic>> refreshTokenFn(
    String refreshToken,
  ) async {
    try {
      await checkConnectivityAndMakeApiCall();
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
      rethrow;
    }
  }
}
