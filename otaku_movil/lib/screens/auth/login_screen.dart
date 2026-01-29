import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/notification_service.dart';  // 🔥 AGREGAR

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();

      await auth.login(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
      );

      if (!mounted) return;

      // Ir a PROFILE y limpiar historial
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
        arguments: {'tab': 3}, // abre directamente Perfil
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Credenciales inválidas o error de red')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // 🔥 MÉTODO DE PRUEBA DE NOTIFICACIONES
  Future<void> _testNotification() async {
    print('🧪 [TEST] Probando notificación manual...');
    
    try {
      await NotificationService().showNotification(
        id: 999,
        title: '🧪 TEST MANUAL',
        body: 'Si ves esto, las notificaciones funcionan correctamente',
        payload: 'test',
      );
      print('🧪 [TEST] Notificación enviada');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notificación enviada. ¿La viste aparecer?'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      print('❌ [TEST] Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7EEF2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Image.asset('assets/img/secundario1.png', height: 140),
                const SizedBox(height: 10),
                const Text(
                  'Bienvenido',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _emailCtrl,
                  enabled: !_loading,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingrese su email'
                      : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passCtrl,
                  enabled: !_loading,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) => (v == null || v.isEmpty)
                      ? 'Ingrese su contraseña'
                      : null,
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Acceso'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                Navigator.pushNamed(
                                    context, AppRoutes.register);
                              },
                        child: const Text('Registrarse'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () {
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.catalogo,
                            (route) => false,
                          );
                        },
                  child: const Text('Continuar como invitado'),
                ),
                
                // 🔥 BOTÓN DE PRUEBA DE NOTIFICACIONES
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _testNotification,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text('🧪 Probar Notificación'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: const BorderSide(color: Colors.orange),
                  ),
                ),
                
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: _loading ? null : () {},
                  child: const Text(
                    '¿SE OLVIDÓ SU CONTRASEÑA?',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
