import 'package:flutter/foundation.dart';
import '../models/orden_resumen.dart';
import '../models/orden_detalle.dart';
import '../models/orden_estado_historial.dart';
import '../services/order_service.dart';

class OrdersProvider extends ChangeNotifier {
  final OrderService _service;
  OrdersProvider(this._service);

  bool loading = false;
  String? error;

  List<OrdenResumen> ordenes = [];
  OrdenDetalle? ordenDetalle;
  List<OrdenEstadoHistorial> historial = [];

  Future<void> loadOrdenes({required int usuarioId}) async {
    loading = true; error = null; notifyListeners();
    try {
     ordenes = await _service.getMisOrdenes(usuarioId: usuarioId);
 
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }

  Future<void> loadDetalle({required int ordenId, required int usuarioId}) async {
    loading = true; error = null; notifyListeners();
    try {
      ordenDetalle = await _service.getOrdenDetalle(ordenId: ordenId, usuarioId: usuarioId);
      historial = await _service.getHistorialEstados(ordenId: ordenId, usuarioId: usuarioId);
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false; notifyListeners();
    }
  }
}
