

// lib/utils/date_utils.dart
import 'package:intl/intl.dart';

class DateUtils {
  static String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No disponible';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy HH:mm');
      return formatter.format(date);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  static String formatDateOnly(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No disponible';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('dd/MM/yyyy');
      return formatter.format(date);
    } catch (e) {
      return 'Fecha inválida';
    }
  }

  static String formatTimeOnly(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No disponible';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final formatter = DateFormat('HH:mm');
      return formatter.format(date);
    } catch (e) {
      return 'Hora inválida';
    }
  }

  static String formatRelativeTime(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'No disponible';
    }
    
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 7) {
        return formatDate(dateString);
      } else if (difference.inDays > 0) {
        return 'Hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'Hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'Hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'Hace un momento';
      }
    } catch (e) {
      return 'Fecha inválida';
    }
  }
}