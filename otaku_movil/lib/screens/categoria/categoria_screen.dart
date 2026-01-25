// lib/screens/categoria/categoria_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/producto_provider.dart';
import '../../models/producto.dart';


class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({Key? key}) : super(key: key);

  @override
  State<CategoriaScreen> createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  String _generoActual = 'mujer';
  String _tipoActual = 'novedad';

  @override
  void initState() {
    super.initState();
    // Cargar productos al inicializar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductoProvider>().getProductosByGeneroYTipo(
        _generoActual, 
        _tipoActual
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      final nuevoGenero = args['genero'] ?? 'mujer';
      final nuevoTipo = args['tipo'] ?? 'novedad';
      
      if (nuevoGenero != _generoActual || nuevoTipo != _tipoActual) {
        setState(() {
          _generoActual = nuevoGenero;
          _tipoActual = nuevoTipo;
        });
        
        context.read<ProductoProvider>().getProductosByGeneroYTipo(
          _generoActual, 
          _tipoActual
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 22),
          onPressed: () => Navigator.pop(context),
          padding: const EdgeInsets.all(12),
        ),
        title: const Text(
          'Ver por categoría',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.tune, color: Colors.black, size: 20),
              ),
              onPressed: () => _mostrarFiltroDialogo(context),
              tooltip: 'Filtros',
            ),
          ),
        ],
      ),
      body: Consumer<ProductoProvider>(
        builder: (context, provider, child) {
          return Column(
            children: [
              // ✅ FILTROS SUPERIORES - CARRUSEL HORIZONTAL MEJORADO
              Container(
                width: screenWidth,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título de sección
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Text(
                        'Categorías',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    
                    // Carrusel de filtros
                    SizedBox(
                      height: 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        physics: const BouncingScrollPhysics(),
                        children: [
                          // HOMBRE
                          _buildFilterChipHorizontal(
                            'Novedades Hombre',
                            _tipoActual == 'novedades' && _generoActual == 'hombre',
                            'hombre',
                            'novedades',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChipHorizontal(
                            'NTX Prom Hombre',
                            _tipoActual == 'ntx_prom' && _generoActual == 'hombre',
                            'hombre',
                            'ntx_prom',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChipHorizontal(
                            'Uniformes Deportivas',
                            _tipoActual == 'uniformes_deportivas' && _generoActual == 'hombre',
                            'hombre',
                            'uniformes_deportivas',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChipHorizontal(
                            'Corporativa Hombre',
                            _tipoActual == 'ropa_corporativa' && _generoActual == 'hombre',
                            'hombre',
                            'ropa_corporativa',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          
                          // MUJER
                          _buildFilterChipHorizontal(
                            'Novedades Mujer',
                            _tipoActual == 'novedades' && _generoActual == 'mujer',
                            'mujer',
                            'novedades',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChipHorizontal(
                            'Corporativa Mujer',
                            _tipoActual == 'ropa_corporativa' && _generoActual == 'mujer',
                            'mujer',
                            'ropa_corporativa',
                            provider,
                          ),
                          const SizedBox(width: 10),
                          _buildFilterChipHorizontal(
                            'NTX Prom Mujer',
                            _tipoActual == 'ntx_prom' && _generoActual == 'mujer',
                            'mujer',
                            'ntx_prom',
                            provider,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              // Línea divisoria sutil
              Container(
                height: 1,
                color: Colors.grey[200],
              ),

              // CONTENIDO PRINCIPAL
              Expanded(
                child: _buildContent(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ WIDGET MEJORADO PARA CHIPS DE FILTRO
  Widget _buildFilterChipHorizontal(
    String label,
    bool isSelected,
    String genero,
    String tipo,
    ProductoProvider provider,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _generoActual = genero;
          _tipoActual = tipo;
        });
        // Mantener la funcionalidad original
        provider.cargarProductosPorCategoria('${genero}_$tipo');
        provider.generoActual = genero;
        provider.tipoActual = tipo;
        provider.getProductosByGeneroYTipo(genero, tipo);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFF1A1A1A), Color(0xFF2D2D2D)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: isSelected ? null : Colors.grey[100],
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected ? Colors.black : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Container(
                margin: const EdgeInsets.only(right: 6),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[700],
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ CONTENIDO PRINCIPAL CON MEJOR MANEJO DE ESTADOS
  Widget _buildContent(ProductoProvider provider) {
    // Mostrar loading
    if (provider.isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.grey[700],
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Cargando productos...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // Mostrar error
    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red[100],
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Error al cargar productos',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.error ?? 'Ocurrió un error desconocido',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  provider.limpiarError();
                  provider.getProductosByGeneroYTipo(_generoActual, _tipoActual);
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Mostrar productos vacíos
    if (provider.productosFiltrados.isEmpty) {
      return _buildEmptyState();
    }

    // Mostrar grid de productos
    return RefreshIndicator(
      onRefresh: () => provider.getProductosByGeneroYTipo(_generoActual, _tipoActual),
      color: Colors.grey[800],
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            crossAxisSpacing: 12,
            mainAxisSpacing: 16,
          ),
          itemCount: provider.productosFiltrados.length,
          itemBuilder: (context, index) {
            final producto = provider.productosFiltrados[index];
            return GestureDetector(
             
            );
          },
        ),
      ),
    );
  }

  // ✅ EMPTY STATE MEJORADO
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(50),
              ),
              child: Icon(
                Icons.shopping_bag_outlined,
                size: 60,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No hay productos disponibles',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otra categoría o filtro',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _generoActual = 'mujer';
                  _tipoActual = 'novedad';
                });
                context.read<ProductoProvider>().getProductosByGeneroYTipo(
                  _generoActual,
                  _tipoActual,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Ir a categoría predeterminada'),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ DIÁLOGO DE FILTROS MEJORADO Y RESPONSIVO
  void _mostrarFiltroDialogo(BuildContext context) {
    String generoSeleccionado = _generoActual;
    String tipoSeleccionado = _tipoActual;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle visual
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Título
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filtros avanzados',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E50),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.grey[600],
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // GÉNERO
                    Text(
                      'Género',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: generoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona género',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: ['mujer', 'hombre']
                            .map((g) => DropdownMenuItem(
                              value: g,
                              child: Text(
                                g[0].toUpperCase() + g.substring(1),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                            .toList(),
                        onChanged: (v) => setModalState(
                          () => generoSeleccionado = v ?? generoSeleccionado,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // TIPO
                    Text(
                      'Categoría',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[800],
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: DropdownButtonFormField<String>(
                        value: tipoSeleccionado,
                        decoration: const InputDecoration(
                          labelText: 'Selecciona categoría',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                        items: [
                          'novedad',
                          'ropa_corporativa',
                          'ntx_prom',
                          'uniformes_deportivas'
                        ]
                            .map((t) => DropdownMenuItem(
                              value: t,
                              child: Text(
                                t.replaceAll('_', ' ').toUpperCase(),
                                style: const TextStyle(fontSize: 14),
                              ),
                            ))
                            .toList(),
                        onChanged: (v) => setModalState(
                          () => tipoSeleccionado = v ?? tipoSeleccionado,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // BOTONES
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.pop(context),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check, size: 18),
                            label: const Text('Aplicar'),
                            onPressed: () {
                              Navigator.pop(context);
                              
                              // Actualizar estado local
                              setState(() {
                                _generoActual = generoSeleccionado;
                                _tipoActual = tipoSeleccionado;
                              });

                              // Mantener funcionalidad original
                              context.read<ProductoProvider>().cargarProductosPorCategoria(
                                '${generoSeleccionado}_$tipoSeleccionado',
                              );
                              context.read<ProductoProvider>().generoActual = generoSeleccionado;
                              context.read<ProductoProvider>().tipoActual = tipoSeleccionado;
                              
                              // Cargar productos
                              context.read<ProductoProvider>().getProductosByGeneroYTipo(
                                generoSeleccionado,
                                tipoSeleccionado,
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _mostrarDetalleProducto(Producto producto) {
    Navigator.pushNamed(
      context,
      '/producto-detalle',
      arguments: {'producto': producto},
    );
  }
}
