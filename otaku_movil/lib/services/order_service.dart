import 'package:dio/dio.dart';

import '../models/orden_create_response.dart';
import '../models/orden_detalle.dart';
import '../models/orden_estado_historial.dart';
import '../models/orden_resumen.dart';

import 'api_client.dart';

class OrderService {
  final Dio _dio = ApiClient.dio;

  String _toNaiveIsoLocal(DateTime dt) {
    final x = dt.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    String three(int n) => n.toString().padLeft(3, '0');

    return '${x.year}-${two(x.month)}-${two(x.day)}'
        'T${two(x.hour)}:${two(x.minute)}:${two(x.second)}.${three(x.millisecond)}';
  }

  // ✅ Mantener tal cual para no romper checkout
  Future<OrdenCreateResponse> crearOrden({
    required int usuarioId,
    required DateTime pickupAt,
  }) async {
    final res = await _dio.post(
      '/api/ordenes',
      queryParameters: {'usuarioId': usuarioId},
      data: {'pickupAt': _toNaiveIsoLocal(pickupAt)},
    );
    return OrdenCreateResponse.fromJson(res.data as Map<String, dynamic>);
  }

  // ✅ GET /api/ordenes?usuarioId=#
  Future<List<OrdenResumen>> getMisOrdenes({required int usuarioId}) async {
    final res = await _dio.get(
      '/api/ordenes',
      queryParameters: {'usuarioId': usuarioId},
    );
    final list = (res.data as List).cast<dynamic>();
    return list
        .map((e) => OrdenResumen.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ✅ GET /api/ordenes/{id}?usuarioId=#
 Future<OrdenDetalle> getOrdenDetalle({
  required int ordenId,
  required int usuarioId,
}) async {
  final res = await _dio.get(
    '/api/ordenes/$ordenId',
    queryParameters: {'usuarioId': usuarioId},
  );
  // ignore: avoid_print
  print('DETALLE ORDEN $ordenId => ${res.data}');
  return OrdenDetalle.fromJson(res.data as Map<String, dynamic>);
}


  // ✅ GET /api/ordenes/{id}/historial-estados?usuarioId=#
Future<List<OrdenEstadoHistorial>> getHistorialEstados({
  required int ordenId,
  required int usuarioId,
}) async {
  final res = await _dio.get(
    '/api/ordenes/$ordenId/historial-estados',
    queryParameters: {'usuarioId': usuarioId},
  );
  // LOG
  print('HISTORIAL ORDEN $ordenId => ${res.data}');
  final list = (res.data as List).cast<dynamic>();
  return list
      .map((e) => OrdenEstadoHistorial.fromJson(e as Map<String, dynamic>))
      .toList();
}

}
