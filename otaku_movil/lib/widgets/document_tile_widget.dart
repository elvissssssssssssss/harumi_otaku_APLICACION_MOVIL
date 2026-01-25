// lib/widgets/document_tile_widget.dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';
import 'dart:io';
import '../models/seguimiento.dart';

class DocumentTileWidget extends StatelessWidget {
  final DocumentoEnvio documento;
  final String tipoLabel;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final String? fechaFormateada;
  
  const DocumentTileWidget({
    Key? key,
    required this.documento,
    required this.tipoLabel,
    this.onTap,
    this.onDownload,
    this.fechaFormateada,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
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
          tipoLabel,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(documento.nombreArchivo),
            if (fechaFormateada != null)
              Text(
                fechaFormateada!,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onTap != null)
              IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.visibility),
                tooltip: 'Ver documento',
              ),
            if (onDownload != null)
              IconButton(
                onPressed: onDownload,
                icon: const Icon(Icons.download),
                tooltip: 'Descargar documento',
              ),
          ],
        ),
        onTap: onTap,
      ),
    );
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

  // Método para abrir documentos (local o web)
  static Future<void> openDocument(BuildContext context, String rutaArchivo) async {
    try {
      // Si es una URL web
      if (rutaArchivo.startsWith('http')) {
        final uri = Uri.parse(rutaArchivo);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo abrir la URL'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } 
      // Si es un archivo local
      else if (rutaArchivo.startsWith('/')) {
        final file = File(rutaArchivo);
        
        // Verificar si el archivo existe
        if (await file.exists()) {
          final result = await OpenFile.open(rutaArchivo);
          
          if (result.type != ResultType.done) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('No se pudo abrir el archivo: ${result.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('El archivo no existe'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
      // Si no es ni URL ni ruta local válida
      else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Formato de archivo no compatible'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}