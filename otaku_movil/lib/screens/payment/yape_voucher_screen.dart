import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../routes/app_routes.dart';

class YapeVoucherScreen extends StatefulWidget {
  const YapeVoucherScreen({super.key});

  @override
  State<YapeVoucherScreen> createState() => _YapeVoucherScreenState();
}

class _YapeVoucherScreenState extends State<YapeVoucherScreen> {
  final _picker = ImagePicker();
  XFile? _image;
  final _nroCtrl = TextEditingController();

  DateTime? _pickupAt;
  final DateFormat _fmtPickup = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void dispose() {
    _nroCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final img = await _picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    setState(() => _image = img);
  }

  Future<void> _pickPickupAt() async {
    final now = DateTime.now();

    final date = await showDatePicker(
      context: context,
      initialDate: _pickupAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );
    if (date == null) return;
    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_pickupAt ?? now),
    );
    if (time == null) return;

    setState(() {
      _pickupAt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _submit(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final checkout = context.read<CheckoutProvider>();
    final cart = context.read<CartProvider>();
    final sm = ScaffoldMessenger.of(context);

    if (!auth.isAuthenticated || auth.userId == null) {
      sm.showSnackBar(const SnackBar(content: Text('Inicia sesión')));
      return;
    }

    final items = cart.cart?.items ?? const [];
    if (items.isEmpty) {
      sm.showSnackBar(const SnackBar(content: Text('Tu carrito está vacío')));
      return;
    }

    if (_pickupAt == null) {
      sm.showSnackBar(const SnackBar(content: Text('Selecciona fecha y hora de recojo')));
      return;
    }
// rango permitido: 8:00 a 23:00 (hora local del día elegido)
final pickup = _pickupAt!;
final start = DateTime(pickup.year, pickup.month, pickup.day, 8, 0);
final end = DateTime(pickup.year, pickup.month, pickup.day, 23, 0);

if (pickup.isBefore(start) || pickup.isAfter(end)) {
  sm.showSnackBar(
    const SnackBar(content: Text('El recojo debe ser entre 8:00 am y 11:00 pm')),
  );
  return;
}
if (pickup.isBefore(DateTime.now())) {
  sm.showSnackBar(const SnackBar(content: Text('No puedes elegir una hora en el pasado')));
  return;
}


    final nro = _nroCtrl.text.trim();
    if (_image == null) {
      sm.showSnackBar(const SnackBar(content: Text('Selecciona la imagen del voucher')));
      return;
    }
    if (nro.isEmpty) {
      sm.showSnackBar(const SnackBar(content: Text('Ingresa el Nro de operación')));
      return;
    }

    await checkout.generarPagoYape(
      usuarioId: auth.userId!,
      pickupAt: _pickupAt!, // hora local Perú
      yapeQrPayload: '435353553',
      nota: 'Pago por voucher',
      forceNew: true,
    );

    if (!mounted) return;

    if (checkout.error != null || checkout.pago == null) {
      sm.showSnackBar(SnackBar(content: Text('Error generando pago: ${checkout.error}')));
      return;
    }

    await checkout.subirVoucher(
      usuarioId: auth.userId!,
      pagoId: checkout.pago!.id,
      imagePath: _image!.path,
      nroOperacion: nro,
    );

    if (!mounted) return;

    if (checkout.error == null) {
      await cart.refresh(usuarioId: auth.userId!);
      if (!mounted) return;

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.pendienteValidacion,
        arguments: {
          'ordenId': checkout.orden?.id,
          'pagoId': checkout.pago?.id,
          'estado': checkout.pago?.estado,
        },
      );
    } else {
      sm.showSnackBar(SnackBar(content: Text('Error subiendo voucher: ${checkout.error}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final checkout = context.watch<CheckoutProvider>();
    final cartProv = context.watch<CartProvider>();

    if (!auth.isAuthenticated || auth.userId == null) {
      return const Scaffold(body: Center(child: Text('Inicia sesión')));
    }

    // Bloquear pantalla pago si carrito vacío
    final items = cartProv.cart?.items ?? const [];
    if (cartProv.loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (cartProv.error != null) {
      return Scaffold(body: Center(child: Text('Error carrito: ${cartProv.error}')));
    }
    if (items.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Tu carrito está vacío. Agrega productos antes de pagar.')),
      );
    }

    final canSubmit =
        _pickupAt != null && _image != null && _nroCtrl.text.trim().isNotEmpty && !checkout.loading;

    return Scaffold(
      backgroundColor: const Color(0xFFF7EEF2),
      appBar: AppBar(title: const Text('Pago Yape (Voucher)')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            if (checkout.error != null)
              Text('Error: ${checkout.error}', style: const TextStyle(color: Colors.red)),

            OutlinedButton(
              onPressed: checkout.loading ? null : _pickPickupAt,
              child: Text(
                _pickupAt == null
                    ? 'Elegir fecha y hora de recojo'
                    : 'Recojo: ${_fmtPickup.format(_pickupAt!.toLocal())}',
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: checkout.loading ? null : _pickImage,
              child: const Text('Seleccionar imagen voucher'),
            ),

            const SizedBox(height: 10),

            if (_image != null)
              SizedBox(
                height: 140,
                child: Image.file(File(_image!.path), fit: BoxFit.cover),
              ),

            const SizedBox(height: 10),

            TextField(
              controller: _nroCtrl,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                labelText: 'Nro Operación',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: canSubmit ? () => _submit(context) : null,
                child: Text(checkout.loading ? 'Enviando...' : 'Subir voucher'),
              ),
            ),

            const SizedBox(height: 12),

            if (checkout.orden != null) Text('OrdenId: ${checkout.orden!.id}'),
            if (checkout.pago != null) Text('PagoId: ${checkout.pago!.id}  Estado: ${checkout.pago!.estado}'),
          ],
        ),
      ),
    );
  }
}
