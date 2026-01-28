import 'package:flutter/foundation.dart';
import '../models/orden_create_response.dart';
import '../models/pago_yape.dart';
import '../services/order_service.dart';
import '../services/payment_service.dart';

class CheckoutProvider extends ChangeNotifier {
  final OrderService _orderService;
  final PaymentService _paymentService;

  CheckoutProvider(this._orderService, this._paymentService);

  bool loading = false;
  String? error;

  OrdenCreateResponse? orden;
  PagoYape? pago;

  void reset() {
    loading = false;
    error = null;
    orden = null;
    pago = null;
    notifyListeners();
  }

  Future<void> crearOrden({
    required int usuarioId,
    required DateTime pickupAt,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      orden = await _orderService.crearOrden(usuarioId: usuarioId, pickupAt: pickupAt);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> iniciarYape({
    required int usuarioId,
    required int ordenId,
    required String yapeQrPayload,
    String? nota,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      pago = await _paymentService.iniciarPagoYape(
        usuarioId: usuarioId,
        ordenId: ordenId,
        yapeQrPayload: yapeQrPayload,
        nota: nota,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// 1 solo paso: crea la orden (si no existe) y luego inicia Yape (si no existe).
  Future<void> generarPagoYape({
    required int usuarioId,
    required DateTime pickupAt,
    required String yapeQrPayload,
    String? nota,
    bool forceNew = false,
  }) async {
    loading = true;
    error = null;

    if (forceNew) {
      orden = null;
      pago = null;
    }

    notifyListeners();

    try {
      // Crear orden si no hay
      orden ??= await _orderService.crearOrden(usuarioId: usuarioId, pickupAt: pickupAt);

      // Iniciar Yape si no hay
      pago ??= await _paymentService.iniciarPagoYape(
        usuarioId: usuarioId,
        ordenId: orden!.id,
        yapeQrPayload: yapeQrPayload,
        nota: nota,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> subirVoucher({
    required int usuarioId,
    required int pagoId,
    required String imagePath,
    required String nroOperacion,
  }) async {
    loading = true;
    error = null;
    notifyListeners();

    try {
      pago = await _paymentService.subirVoucher(
        usuarioId: usuarioId,
        pagoId: pagoId,
        imagePath: imagePath,
        nroOperacion: nroOperacion,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
