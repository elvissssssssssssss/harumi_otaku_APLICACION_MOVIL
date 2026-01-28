import 'package:dio/dio.dart';
import '../models/pago_yape.dart';
import 'api_client.dart';

class PaymentService {
  final Dio _dio = ApiClient.dio;

  Future<PagoYape> iniciarPagoYape({
    required int usuarioId,
    required int ordenId,
    required String yapeQrPayload,
    String? nota,
  }) async {
    final res = await _dio.post(
      '/api/ordenes/$ordenId/pago/yape/iniciar',
      queryParameters: {'usuarioId': usuarioId},
      data: {
        'yapeQrPayload': yapeQrPayload,
        if (nota != null) 'nota': nota,
      },
    );
    return PagoYape.fromJson(res.data as Map<String, dynamic>);
  }

  Future<PagoYape> subirVoucher({
    required int usuarioId,
    required int pagoId,
    required String imagePath,
    required String nroOperacion,
  }) async {
    final formData = FormData.fromMap({
      'Imagen': await MultipartFile.fromFile(imagePath),
      'NroOperacion': nroOperacion,
    });

    final res = await _dio.post(
      '/api/pagos/$pagoId/voucher',
      queryParameters: {'usuarioId': usuarioId},
      data: formData,
    );

    return PagoYape.fromJson(res.data as Map<String, dynamic>);
  }
}
