// ==================== core/utils/helpers.dart ====================
import 'package:intl/intl.dart';

class Helpers {
  // Formatear fecha
  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  // Formatear fecha y hora
  static String formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  // Fecha relativa
  static String getRelativeDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return 'Ahora';
        }
        return '${difference.inMinutes}m';
      }
      return '${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Mañana';
    } else if (difference.inDays == -1) {
      return 'Ayer';
    } else if (difference.inDays > 0 && difference.inDays < 7) {
      return 'En ${difference.inDays} días';
    } else if (difference.inDays < 0 && difference.inDays > -7) {
      return 'Hace ${-difference.inDays} días';
    }

    return formatDate(date);
  }

  // Validar email
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Capitalizar primera letra
  static String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}
