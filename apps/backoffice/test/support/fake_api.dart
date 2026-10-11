import 'package:backoffice/core/api/api_client.dart';

/// Cliente de API falso para pruebas: devuelve listas controladas sin red.
class FakeApi extends ApiClient {
  FakeApi({
    this.controlTower = const <Map<String, dynamic>>[],
    this.orders = const <Map<String, dynamic>>[],
    this.claims = const <Map<String, dynamic>>[],
    this.connections = const <Map<String, dynamic>>[],
  });

  final List<Map<String, dynamic>> controlTower;
  final List<Map<String, dynamic>> orders;
  final List<Map<String, dynamic>> claims;
  final List<Map<String, dynamic>> connections;

  @override
  Future<List<Map<String, dynamic>>> getControlTower() async => controlTower;

  @override
  Future<List<Map<String, dynamic>>> getOrders() async => orders;

  @override
  Future<List<Map<String, dynamic>>> getClaims() async => claims;

  @override
  Future<List<Map<String, dynamic>>> getConnections() async => connections;
}
