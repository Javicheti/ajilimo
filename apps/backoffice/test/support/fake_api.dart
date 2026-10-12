import 'package:backoffice/core/api/api_client.dart';

/// Cliente de API falso para pruebas: devuelve listas controladas sin red.
class FakeApi extends ApiClient {
  FakeApi({
    this.controlTower = const <Map<String, dynamic>>[],
    this.orders = const <Map<String, dynamic>>[],
    this.claims = const <Map<String, dynamic>>[],
    this.connections = const <Map<String, dynamic>>[],
    this.brands = const <Map<String, dynamic>>[],
  });

  final List<Map<String, dynamic>> controlTower;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> claims;
  final List<Map<String, dynamic>> connections;
  final List<Map<String, dynamic>> brands;

  @override
  Future<({List<Map<String, dynamic>> rows, String? generatedAt})> getControlTower({String? brand}) async =>
      (rows: controlTower, generatedAt: null);

  @override
  Future<({List<Map<String, dynamic>> brands, String? defaultBrandId})> getBrands() async =>
      (brands: brands, defaultBrandId: null);

  @override
  Future<List<Map<String, dynamic>>> getOrders() async => orders;

  @override
  Future<List<Map<String, dynamic>>> getClaims() async => claims;

  @override
  Future<List<Map<String, dynamic>>> getConnections() async => connections;

  @override
  Future<Map<String, dynamic>> getReports() async => <String, dynamic>{'source': 'none'};

  @override
  Future<List<Map<String, dynamic>>> getMenu() async => <Map<String, dynamic>>[];
}
