import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cliente del BFF de AjíLimo. La URL base es configurable con
/// `--dart-define=API_BASE_URL=...`; por defecto apunta al emulador local de
/// funciones (que a su vez lee de los mocks).
class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'http://127.0.0.1:5001/ajilimo-830ca/us-central1/api',
            ),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<List<Map<String, dynamic>>> getControlTower() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/control-tower'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['rows'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getConnections() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/connections'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['integrations'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getOrders() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/orders'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['orders'] as List<dynamic>).cast<Map<String, dynamic>>();
  }

  Future<List<Map<String, dynamic>>> getClaims() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/claims'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['claims'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
