import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class PendienteValidacionScreen extends StatelessWidget {
  const PendienteValidacionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = (ModalRoute.of(context)?.settings.arguments as Map?) ?? {};

    final ordenId = args['ordenId'];
    final pagoId = args['pagoId'];
    final estado = args['estado'] ?? 'EN_REVISION';

    return Scaffold(
      appBar: AppBar(title: const Text('Pago pendiente')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tu voucher fue enviado y está pendiente de validación.'),
            const SizedBox(height: 12),
            Text('Estado: $estado'),
            if (ordenId != null) Text('OrdenId: $ordenId'),
            if (pagoId != null) Text('PagoId: $pagoId'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
               onPressed: () {
  Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.home,
    (route) => false,
    arguments: {'tab': 0}, // 0=catalogo, 1=carrito
  );
},
                child: const Text('Volver al inicio'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
