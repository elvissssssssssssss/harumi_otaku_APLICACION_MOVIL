import 'package:flutter/material.dart';

class RecojoScreen extends StatefulWidget {
  const RecojoScreen({super.key});

  @override
  State<RecojoScreen> createState() => _RecojoScreenState();
}

class _RecojoScreenState extends State<RecojoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _horaController = TextEditingController(text: '5:30');
  TimeOfDay _selectedTime = TimeOfDay(hour: 5, minute: 30);

  @override
  void dispose() {
    _nombreController.dispose();
    _horaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFFCE4EC), // Fondo rosa claro
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // Barra de navegación superior
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildHeaderItem(
                  Icons.category,
                  'Catálogo',
                  true,
                ),
                _buildHeaderItem(
                  Icons.shopping_cart_outlined,
                  'carrito',
                  true,
                ),
                _buildHeaderItem(Icons.payment, 'pago', true),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recojo en tienda',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // Nombre de quien recoge
                      const Text(
                        'Nombre',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nombreController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.pink[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          hintText: 'Kaory Rodriguez',
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese el nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      
                      // Hora de recojo
                      const Text(
                        'Hora de recojo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _horaController,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.pink[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(30),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          hintText: '5:30',
                        ),
                        readOnly: true,
                        onTap: () async {
                          final TimeOfDay? picked = await showTimePicker(
                            context: context,
                            initialTime: _selectedTime,
                          );
                          if (picked != null && picked != _selectedTime) {
                            setState(() {
                              _selectedTime = picked;
                              _horaController.text = '${picked.hour}:${picked.minute.toString().padLeft(2, '0')}';
                            });
                          }
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Imagen de personaje
                      Center(
                        child: Image.asset(
                          'assets/img/secundario1.png',
                          height: 200,
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Botón de guardar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              // Procesar la solicitud de recojo
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Información guardada'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              
                              // Navegar de vuelta al catálogo
                              Future.delayed(const Duration(seconds: 2), () {
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  'catalogo',
                                  (route) => false,
                                );
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            'Guardar',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderItem(IconData icon, String label, bool isActive) {
    return Column(
      children: [
        Icon(icon, color: isActive ? Colors.black : Colors.grey),
        Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.black : Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
