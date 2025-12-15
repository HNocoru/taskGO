// ==================== core/network/api_endpoints.dart ====================
class ApiEndpoints {
  // Base URL - CAMBIAR SEGÚN TU CONFIGURACIÓN
  static const String baseUrl = 'http://localhost:3000'; // Android Emulator
  // static const String baseUrl = 'http://localhost:3000'; // iOS Simulator
  // static const String baseUrl = 'http://TU_IP:3000'; // Dispositivo físico

  // Auth endpoints
  static const String login = '/api/auth/login';
  static const String register = '/api/auth/register';
  static const String profile = '/api/auth/profile';
  static const String refresh = '/api/auth/refresh';

  // Tasks endpoints
  static const String tasks = '/api/tasks';
  static String taskById(String id) => '/api/tasks/$id';
  static String completeTask(String id) => '/api/tasks/$id/complete';

  // Image endpoints
  static String uploadImage(String taskId) => '/api/tasks/$taskId/image';
  static String deleteImage(String taskId) => '/api/tasks/$taskId/image';

  // Reminder endpoints
  static String reminders(String taskId) => '/api/tasks/$taskId/reminders';
  static String reminderById(String id) => '/api/reminders/$id';
}
