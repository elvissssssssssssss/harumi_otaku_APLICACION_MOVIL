// lib/screens/perfil/seguimiento/seguimiento_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart'; // Agregar esta dependencia
import '../../../providers/seguimiento_provider.dart';
import '../../../models/seguimiento.dart';
import '../../../widgets/loading_widget.dart';
import '../../../widgets/message_widget.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

// Clase de constantes de API
// Clase de constantes de API
class ApiConstants {
  static const String baseUrl = 'https://pusher-backend-elvis.onrender.com'; // URL base de tu API

  // Construir URL de imágenes
  static String getImageUrl(String rutaArchivo) {
    // Si ya es una URL completa, devolverla tal cual
    if (rutaArchivo.startsWith('http')) {
      return rutaArchivo.replaceFirst('localhost', '10.0.2.2');
    }

    // Normalizar rutas locales
    String cleanedPath = rutaArchivo
        .replaceAll(RegExp(r'^wwwroot[\\\/]+'), '') // Elimina 'wwwroot/'
        .replaceAll(RegExp(r'^[\\\/]+'), '') // Elimina barras iniciales
        .replaceAll('\\', '/'); // Cambia '\' por '/'

    return '$baseUrl/$cleanedPath';
  }

  // Construir URL de documentos (PDF, DOC, etc.)
  static String getDocumentUrl(String rutaArchivo) {
    // Si ya es una URL completa, devolverla tal cual
    if (rutaArchivo.startsWith('http')) {
      return rutaArchivo.replaceFirst('localhost', '10.0.2.2');
    }

    // Normalizar rutas locales
    String cleanedPath = rutaArchivo
        .replaceAll(RegExp(r'^wwwroot[\\\/]+'), '')
        .replaceAll(RegExp(r'^[\\\/]+'), '')
        .replaceAll('\\', '/');

    return '$baseUrl/$cleanedPath';
  }
}

class ProfileTrackingScreen extends StatefulWidget {
  const ProfileTrackingScreen({Key? key}) : super(key: key);

  @override
  State<ProfileTrackingScreen> createState() => _ProfileTrackingScreenState();
}

class _ProfileTrackingScreenState extends State<ProfileTrackingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ventaIdController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    _ventaIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seguimiento de Pedidos'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSearchCard(),
            const SizedBox(height: 20),
            Consumer<TrackingProvider>(
              builder: (context, provider, child) {
                if (provider.message.isNotEmpty) {
                  return Column(
                    children: [
                      MessageWidget(
                        message: provider.message,
                        isError: provider.isError,
                        onDismiss: () => provider.clearMessage(),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                }

                if (provider.ventaSeleccionada != null) {
                  return Column(
                    children: [
                      _buildTrackingCard(provider),
                      const SizedBox(height: 16),
                      _buildDocumentsCard(provider),
                      const SizedBox(height: 16),
                      if (provider.puedeConfirmarEntrega())
                        _buildConfirmDeliveryCard(provider),
                    ],
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchCard() {
    return Consumer<TrackingProvider>(
      builder: (context, provider, child) {
        return Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.search, color: Theme.of(context).primaryColor),
                    const SizedBox(width: 8),
                    const Text(
                      'Buscar Con Tu ID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ventaIdController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            hintText: 'Ingrese ID de venta',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.numbers),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingrese un ID de venta';
                            }
                            if (int.tryParse(value) == null) {
                              return 'Ingrese un número válido';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: provider.isLoading ? null : _buscarEnvio,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.search),
                                  SizedBox(width: 4),
                                  Text('Buscar'),
                                ],
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTrackingCard(TrackingProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.local_shipping,
                    color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  'Seguimiento - Venta #${provider.ventaSeleccionada}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Progress bar
            _buildProgressBar(provider),
            const SizedBox(height: 20),

            if (provider.seguimientos.isEmpty)
              const Center(
                child: Text(
                  'No hay seguimientos registrados',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.seguimientos.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final seguimiento = provider.seguimientos[index];
                  return _buildTrackingItem(seguimiento, index + 1, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(TrackingProvider provider) {
    final progreso = provider.getProgreso() / 100;
    final colorActual = _hexToColor(provider.getColorEstadoActual());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Progreso del envío:',
                style: TextStyle(fontWeight: FontWeight.w500)),
            Text('${(progreso * 100).toInt()}%',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        LinearProgressIndicator(
          value: progreso,
          backgroundColor: Colors.grey[300],
          valueColor: AlwaysStoppedAnimation<Color>(colorActual),
          minHeight: 6,
        ),
      ],
    );
  }

  Widget _buildTrackingItem(
      SeguimientoEnvio seguimiento, int numero, TrackingProvider provider) {
    final estadoInfo = EstadosEnvio.getEstado(seguimiento.estadoId);
    final color =
        estadoInfo != null ? _hexToColor(estadoInfo.color) : Colors.blue;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Círculo numerado
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              numero.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),

        // Contenido del seguimiento
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  seguimiento.estadoNombre ?? 'Estado desconocido',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                if (seguimiento.estadoDescripcion != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    seguimiento.estadoDescripcion!,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Ubicación: ${seguimiento.ubicacionActual}',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (seguimiento.observaciones.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Observaciones: ${seguimiento.observaciones}'),
                ],
                const SizedBox(height: 8),
                Text(
                  provider.formatearFecha(seguimiento.fechaCambio),
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (seguimiento.confirmadoPorCliente == true) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, color: Colors.white, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Confirmado por cliente',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocumentsCard(TrackingProvider provider) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.description, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Documentos',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (provider.documentos.isEmpty)
              const Center(
                child: Text(
                  'No hay documentos registrados',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: provider.documentos.length,
                separatorBuilder: (context, index) => const Divider(),
                itemBuilder: (context, index) {
                  final documento = provider.documentos[index];
                  return _buildDocumentItem(documento, provider);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentItem(
      DocumentoEnvio documento, TrackingProvider provider) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          _getDocumentIcon(documento.tipoDocumento),
          color: Theme.of(context).primaryColor,
        ),
      ),
      title: Text(
        provider.getTipoDocumentoLabel(documento.tipoDocumento),
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(documento.nombreArchivo),
          Text(
            provider.formatearFecha(documento.fechaSubida),
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: ElevatedButton.icon(
        onPressed: () => _openDocument(documento, provider),
        icon: const Icon(Icons.visibility, size: 18),
        label: const Text('Ver'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
          foregroundColor: Theme.of(context).primaryColor,
          elevation: 0,
        ),
      ),
    );
  }

  Widget _buildConfirmDeliveryCard(TrackingProvider provider) {
    return Card(
      elevation: 4,
      color: Colors.orange[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange[700]),
                const SizedBox(width: 8),
                Text(
                  'Confirmar Entrega',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '¿Está seguro que desea marcar este envío como entregado?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: provider.isConfirmingDelivery
                    ? null
                    : () => _confirmarEntrega(provider),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: provider.isConfirmingDelivery
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text('Confirmando...'),
                        ],
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check),
                          SizedBox(width: 8),
                          Text('Confirmar Entrega'),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Métodos de acción
  void _buscarEnvio() {
    if (_formKey.currentState!.validate()) {
      final ventaId = int.parse(_ventaIdController.text);
      context.read<TrackingProvider>().buscarEnvio(ventaId);
    }
  }

  void _confirmarEntrega(TrackingProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Entrega'),
        content: const Text(
            '¿Está seguro que desea confirmar la entrega de este pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.confirmarEntrega();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange[600],
              foregroundColor: Colors.white,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _openDocument(DocumentoEnvio documento, TrackingProvider provider) {
    String documentUrl = ApiConstants.getDocumentUrl(documento.rutaArchivo);
    _viewImage(documentUrl);
  }

  // Método para visualizar imágenes
  void _viewImage(String imageUrl) async {
    try {
      print('Visualizando imagen: $imageUrl'); // Para debug

      // Para imágenes del servidor, mostrar en un visor personalizado
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Foto del Envío'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              actions: [
                IconButton(
                  icon: const Icon(Icons.open_in_browser),
                  onPressed: () async {
                    final uri = Uri.parse(imageUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    }
                  },
                  tooltip: 'Abrir en navegador',
                ),
              ],
            ),
            body: Center(
              child: InteractiveViewer(
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  errorWidget: (context, url, error) {
                    print('Error cargando imagen: $error');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar la imagen',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'URL: $imageUrl',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error al visualizar imagen: $e');
      _showError('Error al abrir la imagen: ${e.toString()}');
    }
  }

  // Método alternativo usando Image.network (si no quieres usar cached_network_image)
  void viewImageBasic(String imageUrl) async {
    try {
      print('Visualizando imagen: $imageUrl'); // Para debug

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Foto del Envío'),
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
            ),
            body: Center(
              child: InteractiveViewer(
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.contain,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    print('Error cargando imagen: $error');
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Error al cargar la imagen',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'URL: $imageUrl',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error al visualizar imagen: $e');
      _showError('Error al abrir la imagen: ${e.toString()}');
    }
  }

  // Método para mostrar errores
  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Métodos auxiliares
  Color _hexToColor(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 7) {
      buffer.write(hexString.replaceFirst('#', 'ff'));
    } else {
      buffer.write(hexString.replaceFirst('#', ''));
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  IconData _getDocumentIcon(String tipoDocumento) {
    switch (tipoDocumento) {
      case 'boleta':
        return Icons.receipt;
      case 'foto_envio':
        return Icons.photo_camera;
      case 'guia_remision':
        return Icons.local_shipping;
      case 'comprobante_entrega':
        return Icons.check_circle;
      default:
        return Icons.description;
    }
  }
}
