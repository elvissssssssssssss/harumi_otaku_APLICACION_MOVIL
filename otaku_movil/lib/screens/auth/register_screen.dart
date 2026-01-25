import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/widgets/app_bar_menu.dart';
import '/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  DateTime? _selectedDate;

  bool _obscurePassword = true;
  bool _receiveNewsletters = false;
  bool _acceptPrivacyPolicy = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBarMenu(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8),
        child: Column(
          children: [
            const SizedBox(height: 18),
            const Text(
              "¡Crea tu cuenta!",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 26,
                letterSpacing: 0.3,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Regístrate para una mejor experiencia de compra",
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _campoInput("EMAIL", _emailController, TextInputType.emailAddress, false),
                    const SizedBox(height: 28),
                    _campoInput("CONTRASEÑA", _passwordController, TextInputType.visiblePassword, true),
                    const SizedBox(height: 28),
                    _campoInput("NOMBRE", _nombreController, TextInputType.text, false),
                    const SizedBox(height: 28),
                    _campoInput("APELLIDO", _apellidoController, TextInputType.text, false),
                    const SizedBox(height: 28),

                    // FECHA DE NACIMIENTO (DatePicker)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "FECHA DE NACIMIENTO",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(6),
                      child: IgnorePointer(
                        child: TextField(
                          controller: TextEditingController(
                            text: _selectedDate == null
                                ? ''
                                : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}",
                          ),
                          decoration: InputDecoration(
                            hintText: "Selecciona tu fecha de nacimiento",
                            suffixIcon: const Icon(Icons.calendar_today_outlined),
                            isDense: true,
                            border: const UnderlineInputBorder(),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black, width: 1.3),
                            ),
                          ),
                          readOnly: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    SwitchListTile(
                      title: const Text(
                        "Recibir novedades y ofertas por email",
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                      ),
                      value: _receiveNewsletters,
                      activeColor: Colors.black,
                      onChanged: (v) => setState(() => _receiveNewsletters = v),
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: _acceptPrivacyPolicy,
                          onChanged: (v) => setState(() => _acceptPrivacyPolicy = v!),
                          activeColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                        ),
                        Expanded(
                          child: Text.rich(
                            TextSpan(
                              text: "He leído y acepto la ",
                              style: const TextStyle(fontSize: 11, color: Colors.grey),
                              children: [
                                TextSpan(
                                  text: 'Política de Privacidad',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                    decoration: TextDecoration.underline,
                                  ),
                                )
                              ]
                            ),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _acceptPrivacyPolicy ? _handleRegister : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _acceptPrivacyPolicy ? Colors.black : Colors.grey[400],
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  elevation: 0,
                ),
                child: const Text(
                  'CREAR CUENTA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
          ],
        ),
      ),
    );
  }

  Widget _campoInput(String label, TextEditingController controller, TextInputType tipo, bool isPassword, {String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black54,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          keyboardType: tipo,
          obscureText: isPassword && _obscurePassword,
          decoration: InputDecoration(
            hintText: hint,
            suffixIcon: isPassword ? IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey[600],
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ) : null,
            isDense: true,
            border: const UnderlineInputBorder(),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 1.3),
            ),
          ),
        ),
      ],
    );
  }

  // DatePicker sustituto visual
  Future<void> _pickDate() async {
    DateTime now = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(now.year - 100),
      lastDate: DateTime(now.year - 14, now.month, now.day),
      helpText: 'Selecciona tu fecha de nacimiento',
      cancelText: 'Cancelar',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _handleRegister() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String nombre = _nombreController.text.trim();
    String apellido = _apellidoController.text.trim();
    String fechaNacimiento = _selectedDate == null
        ? ""
        : "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";

    // Validaciones
    if (email.isEmpty || password.isEmpty || nombre.isEmpty || apellido.isEmpty || fechaNacimiento.isEmpty) {
      _showMessage('Por favor complete todos los campos', Colors.red);
      return;
    }

    if (!_isValidEmail(email)) {
      _showMessage('Por favor ingrese un correo válido', Colors.red);
      return;
    }

    if (password.length < 6) {
      _showMessage('La contraseña debe tener al menos 6 caracteres', Colors.red);
      return;
    }

    if (!_acceptPrivacyPolicy) {
      _showMessage('Debe aceptar la política de privacidad', Colors.red);
      return;
    }

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final response = await http.post(
        Uri.parse('https://pusher-backend-elvis.onrender.com/api/Auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'nombre': nombre,
          'apellido': apellido,
          'fecha_nacimiento': fechaNacimiento,
          'receiveNewsletters': _receiveNewsletters,
        }),
      );

      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final success = await authProvider.login(token: data['token']);
        if (success) {
          Navigator.pushReplacementNamed(context, '/profile');
        }
        _showMessage('¡Cuenta creada exitosamente!', Colors.green);
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = errorData['message'] ?? 'Registro fallido';
        _showMessage(errorMessage, Colors.red);
      }
    } catch (e) {
      Navigator.pop(context);
      _showMessage('Error al conectarse con la API: $e', Colors.red);
    }
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
