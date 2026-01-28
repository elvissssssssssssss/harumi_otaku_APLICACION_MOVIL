import 'package:dio/dio.dart';
import '../models/orden_create_response.dart';
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

  Future<OrdenCreateResponse> crearOrden({
    required int usuarioId,
    required DateTime pickupAt,
  }) async {
    final res = await _dio.post(
      '/api/ordenes',
      queryParameters: {'usuarioId': usuarioId},
      data: {'pickupAt': _toNaiveIsoLocal(pickupAt)}, // hora Perú “tal cual”
    );
    return OrdenCreateResponse.fromJson(res.data as Map<String, dynamic>);
  }
}
