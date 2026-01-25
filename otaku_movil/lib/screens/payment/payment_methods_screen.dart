// lib/screens/payment/payment_methods_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../models/cart_item.dart';
import '../../services/mercadopago_service.dart';
import '../../providers/cart_provider.dart';
import '../../providers/shipping_provider.dart';
import '../../providers/auth_provider.dart';

import '../../services/envio_service.dart'; // Ajusta la ruta si es necesario


class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  bool _isProcessingPayment = false;
  WebViewController? _webViewController;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _clearCookies() async {
    try {
      final cookieManager = WebViewCookieManager();
      await cookieManager.clearCookies();
    } catch (e) {
      print('Error clearing cookies: $e');
    }
  }

  // ✅ PROCESAR PAGO DIRECTAMENTE SIN LOGIN
  Future<void> _processMercadoPago(List<CartItem> carrito) async {
    if (carrito.isEmpty) {
      _showSnackBar('Error: El carrito está vacío', isError: true);
      return;
    }
    
    setState(() => _isProcessingPayment = true);
    
    try {
      _showSnackBar('Creando preferencia de pago...', isError: false);
      
      String? checkoutUrl;
      
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final shippingProvider = Provider.of<ShippingProvider>(context, listen: false);
        
        if (authProvider.user != null && shippingProvider.shippingData != null) {
          print('✅ Usando método completo con user y envío');
          
          final preference = await MercadoPagoService.createPreference(
            user: authProvider.user!,
            carrito: carrito,
            envio: shippingProvider.shippingData,
          );
          
          if (preference != null) {
            checkoutUrl = preference['sandbox_init_point'] ?? preference['init_point'];
          }
        } else {
          print('⚠️ Sin user o envío, usando método simple');
          checkoutUrl = await MercadoPagoService.crearPreferencia(carrito);
        }
      } catch (e) {
        print('⚠️ Error con método completo, usando simple: $e');
        checkoutUrl = await MercadoPagoService.crearPreferencia(carrito);
      }
      
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('No se pudo crear la preferencia de pago');
      }
      
      print('🔗 Checkout URL: $checkoutUrl');
      await _clearCookies();
      
      final pagoExitoso = await Navigator.push<bool>(
        context,
        MaterialPageRoute(
          builder: (context) => _buildCheckoutWebView(checkoutUrl!),
          fullscreenDialog: true,
        ),
      );
      
      if (!mounted) return;
      
      if (pagoExitoso == true) {
        final cart = Provider.of<CartProvider>(context, listen: false);
        final shippingProvider = Provider.of<ShippingProvider>(context, listen: false);
        final totalConEnvio = cart.total + 15.65;
        await _completePurchase(shippingProvider, cart.items, totalConEnvio);
      } else {
        _showSnackBar('Pago cancelado o no completado', isError: true);
      }
    } catch (e) {
      print('❌ Error: $e');
      _showSnackBar('Error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  // ✅ WEBVIEW PARA CHECKOUT (PAGO DIRECTO)
  Widget _buildCheckoutWebView(String checkoutUrl) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF009EE3),
        elevation: 2,
        title: const Row(
          children: [
            Icon(Icons.payment, color: Colors.white, size: 24),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mercado Pago',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'TEXTILSAC - Pago Seguro',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context, false),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () => _webViewController?.reload(),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 3,
            color: Colors.grey[200],
            child: const LinearProgressIndicator(
              color: Color(0xFF009EE3),
              backgroundColor: Colors.transparent,
            ),
          ),
          Expanded(
            child: WebViewWidget(
              controller: (_webViewController = WebViewController()
                ..setJavaScriptMode(JavaScriptMode.unrestricted)
                ..setUserAgent(
                  'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36'
                )
                ..setNavigationDelegate(
                  NavigationDelegate(
                    onPageStarted: (String url) {
                      print('🔄 Cargando: $url');
                    },
                    onPageFinished: (String url) {
                      print('✅ Cargado: $url');
                      
                      if (_isSuccessUrl(url)) {
                        print('🎉 PAGO EXITOSO - Registrando venta...');
                        Future.delayed(const Duration(milliseconds: 2000), () {
                          if (mounted) {
                            Navigator.pop(context, true);
                          }
                        });
                      } else if (_isFailureUrl(url)) {
                        print('❌ PAGO FALLIDO');
                        Future.delayed(const Duration(milliseconds: 1000), () {
                          if (mounted) {
                            Navigator.pop(context, false);
                          }
                        });
                      }
                    },
                    onWebResourceError: (WebResourceError error) {
                      print('🚨 Error: ${error.description}');
                    },
                  ),
                )
                ..loadRequest(Uri.parse(checkoutUrl))),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: const Row(
              children: [
                Icon(Icons.security, color: Color(0xFF27AE60), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Pago protegido por MercadoPago',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isSuccessUrl(String url) {
    print('🔍 Verificando URL: $url');
    
    final patterns = [
      'success',
      'approved',
      'congrats',
      'payment_status=approved',
      'collections/status=approved',
      'tools/receipt',
      'payment-flow-state=success',
      
    ];
    
    final isSuccess = patterns.any((p) => url.toLowerCase().contains(p));
    
    if (isSuccess) {
      print('✅ ÉXITO DETECTADO: $url');
    }
    
    return isSuccess;
  }

  bool _isFailureUrl(String url) {
    print('🔍 Verificando fallo: $url');
    
    final patterns = [
      'failure',
      'cancelled',
      'rejected',
      'payment_status=rejected',
      'receipt-error',
      'pending',
      'in_process',
    ];
    
    final isFail = patterns.any((p) => url.toLowerCase().contains(p));
    
    if (isFail) {
      print('❌ FALLO DETECTADO: $url');
    }
    
    return isFail;
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final shippingProvider = Provider.of<ShippingProvider>(context);
    const double envio = 15.65;
    final totalConEnvio = cart.total + envio;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildTextilsacHeader(),
          if (shippingProvider.hasShippingData)
            _buildShippingPreview(shippingProvider),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle('Método de Pago'),
                  const SizedBox(height: 16),
                  _buildMercadoPagoOption(cart.items),
                  const SizedBox(height: 20),
                  _buildSecurityInfo(),
                  const SizedBox(height: 16),
                  _buildCheckoutProBadge(),
                ],
              ),
            ),
          ),
          _buildTotalSummary(cart.total, envio, totalConEnvio),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2C3E50), size: 22),
        onPressed: () => Navigator.pop(context),
        padding: const EdgeInsets.all(12),
      ),
      title: const Text(
        'FINALIZAR COMPRA',
        style: TextStyle(
          color: Color(0xFF2C3E50),
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
      centerTitle: true,
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 16),
          child: const Icon(Icons.security, color: Color(0xFF27AE60), size: 24),
        ),
      ],
    );
  }

  Widget _buildTextilsacHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF3498DB), Color(0xFF2980B9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.store, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('TEXTILSAC', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
              Text('Pago seguro con MercadoPago', style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14, fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: Color(0xFF2C3E50),
      ),
    );
  }

  Widget _buildMercadoPagoOption(List<CartItem> carrito) {
    return GestureDetector(
      onTap: _isProcessingPayment ? null : () => _processMercadoPago(carrito),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: _isProcessingPayment ? const Color(0xFF3498DB) : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF009EE3), Color(0xFF0067A3)],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.payment, size: 28, color: Colors.white),
            ),
            const SizedBox(width: 20),
            const Expanded(
              child: Text(
                'Mercado Pago',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF2C3E50)),
              ),
            ),
            if (_isProcessingPayment)
              const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: Color(0xFF3498DB)),
              )
            else
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Color(0xFF3498DB),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSecurityItem('🔒', 'Todos los pagos son protegidos por MercadoPago.'),
        _buildSecurityItem('💳', 'Aceptamos tarjetas, efectivo y transferencias.'),
        _buildSecurityItem('🔎', 'Tus datos estarán seguros y cifrados.'),
      ],
    );
  }

  Widget _buildSecurityItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.3))),
        ],
      ),
    );
  }

  Widget _buildCheckoutProBadge() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF009EE3), Color(0xFF0067A3)]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.verified_user, color: Colors.white, size: 18),
          SizedBox(width: 8),
          Text('Seguridad Garantizada', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildShippingPreview(ShippingProvider shippingProvider) {
    final envio = shippingProvider.shippingData;
    if (envio == null) return const SizedBox.shrink();
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.local_shipping, color: Color(0xFF3498DB), size: 22),
              SizedBox(width: 8),
              Text('Datos de Envío', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF2C3E50))),
            ],
          ),
          const SizedBox(height: 12),
          _buildShippingItem('📍', '${envio.direccion}, ${envio.localidad}'),
          _buildShippingItem('🏙️', '${envio.provincia}, ${envio.region}'),
          _buildShippingItem('🆔', 'DNI: ${envio.dni}'),
          _buildShippingItem('📞', 'Tel: ${envio.telefono}'),
        ],
      ),
    );
  }

  Widget _buildShippingItem(String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: Colors.grey[700]))),
        ],
      ),
    );
  }

  Widget _buildTotalSummary(double subtotal, double envio, double total) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, -2))],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: [
            _buildSummaryRow('Subtotal', subtotal, false),
            const SizedBox(height: 12),
            _buildSummaryRow('Envío', envio, false),
            const Divider(height: 24, thickness: 1.5),
            _buildSummaryRow('Total a Pagar', total, true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isBold ? 18 : 16,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold ? const Color(0xFF2C3E50) : Colors.grey[700],
          ),
        ),
        Text(
          'S/ ${value.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: isBold ? 20 : 16,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? const Color(0xFFBA2323) : const Color(0xFF2C3E50),
          ),
        ),
      ],
    );
  }

Future<void> _completePurchase(ShippingProvider shippingProvider, List<CartItem> carrito, double totalAmount) async {
  try {
    print('🚀 ===== INICIANDO REGISTRO DE ENVÍO Y VENTA =====');

    // 1️⃣ ENVÍA LOS DATOS DE ENVÍO (TblEnvios) ANTES DE REGISTRAR LA VENTA
    final envio = shippingProvider.shippingData!;
    final envioGuardado = await EnvioService().enviarDatos(envio);

    if (!envioGuardado) {
      _showSnackBar('⚠️ No se pudo guardar datos de envío', isError: true);
      return;
    }
    print('✅ ENVÍO GUARDADO EN DB');

    // 2️⃣ REGISTRAR VENTA NORMALMENTE
    final ventaRegistrada = await _registrarVenta(carrito, envio, totalAmount);

    if (ventaRegistrada) {
      print('✅ VENTA REGISTRADA EN DB');
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.clearCart();

      _showSnackBar('🎉 ¡Compra realizada con éxito!', isError: false);
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        print('🏠 Navegando a Home...');
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } else {
      print('⚠️ ERROR: Venta no se registró');
      _showSnackBar('⚠️ Pago exitoso pero error al registrar venta', isError: true);
    }
  } catch (e) {
    print('❌ EXCEPCIÓN: $e');
    _showSnackBar('Error: $e', isError: true);
  }
}


  // lib/screens/payment/payment_methods_screen.dart - REEMPLAZA SOLO _registrarVenta

Future<bool> _registrarVenta(List<CartItem> carrito, dynamic envio, double total) async {
  try {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.user;
    
    if (user == null) {
      print('❌ No hay usuario');
      return false;
    }

    if (carrito.isEmpty) {
      print('❌ Carrito vacío');
      return false;
    }

    // ✅ CONSTRUIR DETALLES COMO ESPERA EL BACKEND .NET
    final detalles = carrito.map((item) => {
      'productoId': item.id,
      'nombreProducto': item.nombre,
      'cantidad': item.cantidad,
      'precioUnitario': item.precio,
    }).toList();

    // ✅ CREAR PAYLOAD EXACTAMENTE COMO LO ESPERA TU .NET
    final payload = {
      'userId': user.id,
      'metodoPagoId': 3,
      'total': total,
      'detalles': detalles,
    };

    print('📤 ===== ENVIANDO VENTA AL BACKEND .NET =====');
    print('URL: https://pusher-backend-elvis.onrender.com/api/Ventas/completa');
    
    final jsonPayload = jsonEncode(payload);
    print('📦 PAYLOAD:');
    print(jsonPayload);

    final response = await http.post(
      Uri.parse('https://pusher-backend-elvis.onrender.com/api/Ventas/completa'),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonPayload,
    ).timeout(const Duration(seconds: 30));

    print('📥 ===== RESPUESTA DEL SERVIDOR =====');
    print('Status: ${response.statusCode}');
    print('Response: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('✅ Venta registrada exitosamente');
      
      try {
        final responseData = jsonDecode(response.body);
        print('ID Venta generado: ${responseData['id']}');
        print('Fecha: ${responseData['fechaVenta']}');
      } catch (e) {
        print('No se pudo parsear respuesta: $e');
      }
      
      return true;
    } else {
      print('❌ Error backend: ${response.body}');
      return false;
    }
  } catch (e) {
    print('🚨 EXCEPCIÓN: $e');
    return false;
  }
}
  

  void _showSnackBar(String message, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(isError ? Icons.error_outline : Icons.check_circle_outline, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: const TextStyle(fontSize: 14))),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE74C3C) : const Color(0xFF27AE60),
        duration: Duration(seconds: isError ? 5 : 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
