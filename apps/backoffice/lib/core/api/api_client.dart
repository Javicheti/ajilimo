import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

/// Cliente del BFF de AjíLimo. La URL base es configurable con
/// `--dart-define=API_BASE_URL=...`; por defecto apunta al BFF desplegado.
class ApiClient {
  ApiClient({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ??
            const String.fromEnvironment(
              'API_BASE_URL',
              defaultValue: 'https://api-mor35f5doa-uc.a.run.app',
            ),
        _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  Future<({List<Map<String, dynamic>> rows, String? generatedAt})> getControlTower({String? brand}) async {
    final Uri uri = Uri.parse('$baseUrl/control-tower').replace(
      queryParameters: brand != null ? <String, String>{'brand': brand} : null,
    );
    final http.Response response = await _client.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      rows: (data['rows'] as List<dynamic>).cast<Map<String, dynamic>>(),
      generatedAt: data['generatedAt'] as String?,
    );
  }

  /// Marcas disponibles (bridge) + marca por defecto.
  Future<({List<Map<String, dynamic>> brands, String? defaultBrandId})> getBrands() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/brands'))
        .timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (
      brands: (data['brands'] as List<dynamic>).cast<Map<String, dynamic>>(),
      defaultBrandId: data['defaultBrandId'] as String?,
    );
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

  /// Reportes/indicadores del bridge (datos reales del Portal Rappi).
  Future<Map<String, dynamic>> getReports() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/reports'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  /// Menú real desde el bridge (Portal Rappi).
  Future<List<Map<String, dynamic>>> getMenu() async {
    final http.Response response = await _client
        .get(Uri.parse('$baseUrl/menu'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }
    final Map<String, dynamic> data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['menus'] as List<dynamic>).cast<Map<String, dynamic>>();
  }
}

final Provider<ApiClient> apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
