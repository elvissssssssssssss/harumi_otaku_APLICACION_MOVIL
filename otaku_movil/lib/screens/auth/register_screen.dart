import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _pass2Ctrl = TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _pass2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();

      await auth.register(
        email: _emailCtrl.text.trim(),
        password: _passCtrl.text,
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
      );

      if (!mounted) return;

      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.catalogo,
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registrando: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Por defecto es true; ayuda a que el teclado no tape inputs/botones. [web:303]
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF7EEF2),
      appBar: AppBar(
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: _loading ? null : () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        Image.asset('assets/img/secundario1.png', height: 140),
                        const SizedBox(height: 10),
                        const Text(
                          'Registro',
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 20),

                        TextFormField(
                          controller: _nombreCtrl,
                          enabled: !_loading,
                          decoration: const InputDecoration(
                            hintText: 'Nombre',
                            prefixIcon: Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese su nombre'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _apellidoCtrl,
                          enabled: !_loading,
                          decoration: const InputDecoration(
                            hintText: 'Apellido',
                            prefixIcon: Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? 'Ingrese su apellido'
                              : null,
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _emailCtrl,
                          enabled: !_loading,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            hintText: 'Email',
                            prefixIcon: Icon(Icons.email_outlined),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
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
                          decoration: const InputDecoration(
                            hintText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Ingrese una contraseña';
                            if (v.length < 6) return 'Mínimo 6 caracteres';
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),

                        TextFormField(
                          controller: _pass2Ctrl,
                          enabled: !_loading,
                          obscureText: true,
                          decoration: const InputDecoration(
                            hintText: 'Repetir contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Repita la contraseña';
                            if (v != _passCtrl.text) return 'Las contraseñas no coinciden';
                            return null;
                          },
                        ),

                        const SizedBox(height: 22),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _loading ? null : _submit,
                            child: _loading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : const Text('Crear cuenta'),
                          ),
                        ),

                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: _loading ? null : () => Navigator.pop(context),
                          child: const Text('Ya tengo cuenta, volver al login'),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
