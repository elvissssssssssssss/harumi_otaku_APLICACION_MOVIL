// lib/screens/payment/payment_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/shipping_provider.dart';
import '../../models/envio.dart';
import '../../routes/app_routes.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State createState() => _PersonalDataFormState();
}

class _PersonalDataFormState extends State {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _direccionController = TextEditingController();
  final TextEditingController _dniController = TextEditingController();
  final TextEditingController _telefonoController = TextEditingController();

  String? _selectedRegion;
  String? _selectedProvincia;
  String? _selectedLocalidad;

  final List<String> _regiones = [
    'Amazonas',
    'Áncash',
    'Apurímac',
    'Arequipa',
    'Ayacucho',
    'Cajamarca',
    'Callao',
    'Cusco',
    'Huancavelica',
    'Huánuco',
    'Ica',
    'Junín',
    'La Libertad',
    'Lambayeque',
    'Lima',
    'Loreto',
    'Madre de Dios',
    'Moquegua',
    'Pasco',
    'Piura',
    'Puno',
    'San Martín',
    'Tacna',
    'Tumbes',
    'Ucayali'
  ];

  final List<String> _provincias = [
    'Lima',
    'Callao',
    'Arequipa',
    'Trujillo',
    'Chiclayo',
    'Huancayo',
    'Piura',
    'Iquitos',
    'Cusco',
    'Chimbote'
  ];

  final List<String> _localidades = [
    'Miraflores',
    'San Isidro',
    'Barranco',
    'Surco',
    'La Molina',
    'San Borja',
    'Pueblo Libre',
    'Magdalena',
    'Jesús María',
    'Lince'
  ];

  @override
  void initState() {
    super.initState();

    // Validación de autenticación
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      if (!authProvider.isAuthenticated) {
        Navigator.pushReplacementNamed(context, '/login');
      }
      
      // Cargar datos si ya existen en el provider
      _loadExistingData();
    });
  }
 
  void _loadExistingData() {
    final shippingProvider = Provider.of<ShippingProvider>(context, listen: false);
    if (shippingProvider.hasShippingData) {
      final data = shippingProvider.shippingData!;
      setState(() {
        _direccionController.text = data.direccion;
        _dniController.text = data.dni;
        // Remover el +51 del teléfono para mostrar solo el número
        _telefonoController.text = data.telefono.replaceFirst('+51', '');
        _selectedRegion = data.region;
        _selectedProvincia = data.provincia;
        _selectedLocalidad = data.localidad;
      });
    }
  }

  // Validación mejorada para DNI
  String? _validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es requerido';
    }
    
    // Remover espacios y guiones
    value = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (value.length != 8) {
      return 'El DNI debe tener exactamente 8 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El DNI solo debe contener números';
    }
    
    // Validar que no sean todos números iguales
    if (RegExp(r'^(\d)\1{7}$').hasMatch(value)) {
      return 'Ingresa un DNI válido';
    }
    
    return null;
  }

  // Validación mejorada para teléfono
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'El teléfono es requerido';
    }
    
    // Remover espacios y guiones
    value = value.replaceAll(RegExp(r'[\s-]'), '');
    
    if (value.length != 9) {
      return 'El teléfono debe tener exactamente 9 dígitos';
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El teléfono solo debe contener números';
    }
    
    // Validar que empiece con 9 (formato peruano para móviles)
    if (!value.startsWith('9')) {
      return 'El teléfono móvil debe empezar con 9';
    }
    
    return null;
  }

  // Validación para dirección
  String? _validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'La dirección es requerida';
    }
    
    if (value.trim().length < 10) {
      return 'Ingresa una dirección más completa (mínimo 10 caracteres)';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black54, size: 28),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título mejorado
              const Text(
                'Datos personales',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w300,
                  color: Colors.black87,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Completa la información para tu envío',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
              const SizedBox(height: 48),
              
              // Card contenedor para mejor organización visual
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      spreadRadius: 1,
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildLabel('Región', required: false),
                    _buildDropdown(
                      value: _selectedRegion,
                      items: _regiones,
                      hint: 'Seleccionar región',
                      onChanged: (value) => setState(() => _selectedRegion = value),
                      validator: (value) => value == null ? 'Selecciona una región' : null,
                    ),
                    const SizedBox(height: 28),
                    
                    _buildLabel('Provincia', required: false),
                    _buildDropdown(
                      value: _selectedProvincia,
                      items: _provincias,
                      hint: 'Seleccionar provincia',
                      onChanged: (value) => setState(() => _selectedProvincia = value),
                      validator: (value) => value == null ? 'Selecciona una provincia' : null,
                    ),
                    const SizedBox(height: 28),
                    
                    _buildLabel('Localidad', required: false),
                    _buildDropdown(
                      value: _selectedLocalidad,
                      items: _localidades,
                      hint: 'Seleccionar localidad',
                      onChanged: (value) => setState(() => _selectedLocalidad = value),
                      validator: (value) => value == null ? 'Selecciona una localidad' : null,
                    ),
                    const SizedBox(height: 28),
                    
                    _buildLabel('DNI', required: true),
                    _buildTextField(
                      controller: _dniController,
                      hintText: 'Ingresa tu DNI (8 dígitos)',
                      keyboardType: TextInputType.number,
                      validator: _validateDNI,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                    ),
                    const SizedBox(height: 28),
                    
                    _buildLabel('Teléfono', required: true),
                    _buildPhoneField(),
                    const SizedBox(height: 28),
                    
                    _buildLabel('Dirección', required: true),
                    _buildTextField(
                      controller: _direccionController,
                      hintText: 'Ej: Av. giraldes 123, x hay',
                      maxLines: 3,
                      validator: _validateAddress,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Botón mejorado
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A5568),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 2,
                    shadowColor: const Color(0xFF4A5568).withOpacity(0.3),
                  ),
                  child: const Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool required = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
          children: required ? [
            const TextSpan(
              text: ' *',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ] : null,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int? maxLines,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines ?? 1,
      validator: validator,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A5568), width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.only(bottom: 16, top: 8),
        errorStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      hint: Text(
        hint,
        style: TextStyle(
          color: Colors.grey[400],
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: const TextStyle(fontSize: 16),
                ),
              ))
          .toList(),
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        border: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF4A5568), width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
        contentPadding: const EdgeInsets.only(bottom: 16, top: 8),
        errorStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: TextFormField(
            initialValue: '+51',
            readOnly: true,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4A5568), width: 2),
              ),
              contentPadding: const EdgeInsets.only(bottom: 16, top: 8),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: TextFormField(
            controller: _telefonoController,
            keyboardType: TextInputType.phone,
            validator: _validatePhone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            decoration: InputDecoration(
              hintText: '9xxxxxxxx',
              hintStyle: TextStyle(
                color: Colors.grey[400],
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Color(0xFF4A5568), width: 2),
              ),
              errorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.red, width: 2),
              ),
              contentPadding: const EdgeInsets.only(bottom: 16, top: 8),
              errorStyle: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() async {
    print("📌 Iniciando _submitForm...");

    if (!_formKey.currentState!.validate()) {
      print("❌ El formulario no es válido");
      return;
    }
    print("✅ Validación de formulario pasada");

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final shippingProvider = Provider.of<ShippingProvider>(context, listen: false);
    final userId = authProvider.userId;

    print("📌 userId: $userId");

    if (userId == null) {
      print("❌ Sesión no válida");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesión no válida. Inicia sesión nuevamente.'),
          backgroundColor: Colors.red,
        ),
      );
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    if (_selectedRegion == null || _selectedProvincia == null || _selectedLocalidad == null) {
      print("❌ Campos de ubicación incompletos");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos de ubicación'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final envio = Envio(
      userId: userId,
      direccion: _direccionController.text.trim(),
      region: _selectedRegion!,
      provincia: _selectedProvincia!,
      localidad: _selectedLocalidad!,
      dni: _dniController.text.trim(),
      telefono: '+51${_telefonoController.text.trim()}',
    );

    print("📦 Datos de envío creados: ${envio.toJson()}");

    shippingProvider.setShippingData(envio);
    print("✅ Datos guardados en provider");

    print("➡️ Navegando a métodos de pago: ${AppRoutes.paymentMethods}");
    Navigator.pushNamed(context, AppRoutes.paymentMethods);
  }

  @override
  void dispose() {
    _direccionController.dispose();
    _dniController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }
}