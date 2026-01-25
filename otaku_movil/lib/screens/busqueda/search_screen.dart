import 'package:flutter/material.dart';
import '../../models/producto.dart';
import '../../services/producto_service.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Producto> _productos = [];
  bool _isLoading = false;
  String _searchText = ""; // <- Corrige el nombre aquí

  void _buscar(String text) async {
    setState(() {
      _searchText = text;
      _isLoading = true;
    });
    // Usa la instancia o static según tu servicio:
    final results = await ProductoService().searchProductos(text);
    setState(() {
      _productos = results;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _buscar(""); // carga todos al inicio
  }
String _getImageUrl(String path) {
  String clean = path.replaceAll('\\', '/');
  if (clean.startsWith('images/') || clean.startsWith('uploads/') || clean.startsWith('wwwroot/')) {
    clean = clean.replaceAll('wwwroot/', '');
    return "https://pusher-backend-elvis.onrender.com/$clean";
  }
  // si ya es url https://
  if (clean.startsWith('http')) return clean;
  // Último fallback
  return "https://pusher-backend-elvis.onrender.com/uploads/$clean";
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Buscar productos"),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black87),
        elevation: 1,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nombre',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(10),
              ),
              onChanged: _buscar,
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(),
            ),
          if (!_isLoading)
            Expanded(
              child: _productos.isEmpty
                  ? const Center(child: Text("No hay resultados"))
                  : ListView.builder(
                      itemCount: _productos.length,
                      itemBuilder: (context, i) {
                        final p = _productos[i];
                        return ListTile(
                          leading: (p.imagen != null && p.imagen!.isNotEmpty)
  ? Image.network(
      _getImageUrl(p.imagen!),
      width: 48,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => 
        const Icon(Icons.image_not_supported, size: 36, color: Colors.grey),
    )
  : const Icon(Icons.image, size: 32, color: Colors.grey),

                          title: Text(p.nombre, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text("S/ ${p.precio}  ${p.marca ?? ''}"),
                          onTap: () {
                            Navigator.pushNamed(context, '/producto_detalle', arguments: {'producto': p});
                          },
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }
}
