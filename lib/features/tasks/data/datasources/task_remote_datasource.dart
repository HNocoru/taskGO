// ==================== features/tasks/data/datasources/task_remote_datasource.dart ====================
import 'dart:io';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_endpoints.dart';
import '../models/task_model.dart';

/// Abstract class que define el contrato para el datasource remoto de tareas
abstract class TaskRemoteDataSource {
  /// Obtiene lista de tareas con filtros opcionales
  Future<List<TaskModel>> getTasks({
    bool? completed,
    String? priority,
    int page = 1,
    int limit = 20,
  });

  /// Obtiene una tarea específica por ID
  Future<TaskModel> getTaskById(String id);

  /// Crea una nueva tarea
  Future<TaskModel> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  });

  /// Actualiza campos específicos de una tarea (PATCH)
  /// ✅ CORRECCIÓN: Este método se acopla con el endpoint PATCH del backend
  Future<TaskModel> updateTask({
    required String id,
    required Map<String, dynamic> updates,
  });

  /// Marca una tarea como completada
  Future<TaskModel> completeTask(String id);

  /// Elimina una tarea
  Future<void> deleteTask(String id);

  /// Sube una imagen a una tarea
  Future<TaskModel> uploadImage(String taskId, File image);

  /// Elimina la imagen de una tarea
  Future<void> deleteImage(String taskId);
}

/// Implementación del datasource que se conecta con la API REST
class TaskRemoteDataSourceImpl implements TaskRemoteDataSource {
  final ApiClient apiClient;

  TaskRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<TaskModel>> getTasks({
    bool? completed,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
    };

    if (completed != null) {
      queryParams['completed'] = completed.toString();
    }

    if (priority != null) {
      queryParams['priority'] = priority;
    }

    final response = await apiClient.get(
      ApiEndpoints.tasks,
      queryParams: queryParams,
    );

    final tasksData = response['data']['tasks'] as List;
    return tasksData.map((json) => TaskModel.fromJson(json)).toList();
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    final response = await apiClient.get(ApiEndpoints.taskById(id));
    return TaskModel.fromJson(response['data']);
  }

  @override
  Future<TaskModel> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final body = <String, dynamic>{
      'title': title,
      if (description != null) 'description': description,
      if (priority != null) 'priority': priority,
      if (dueDate != null) 'dueDate': dueDate.toIso8601String(),
    };

    final response = await apiClient.post(
      ApiEndpoints.tasks,
      body: body,
    );

    return TaskModel.fromJson(response['data']);
  }

  @override
  Future<TaskModel> updateTask({
    required String id,
    required Map<String, dynamic> updates,
  }) async {
    // ✅ CORRECTO: Usa PATCH para actualización parcial
    // Se acopla con el endpoint: PATCH /api/tasks/:id del backend
    final response = await apiClient.patch(
      ApiEndpoints.taskById(id),
      body: updates,
    );

    return TaskModel.fromJson(response['data']);
  }

  @override
  Future<TaskModel> completeTask(String id) async {
    // ✅ CORRECTO: Usa el endpoint específico PATCH /api/tasks/:id/complete
    final response = await apiClient.patch(
      ApiEndpoints.completeTask(id),
      body: {}, // El backend no requiere body para este endpoint
    );

    return TaskModel.fromJson(response['data']);
  }

  @override
  Future<void> deleteTask(String id) async {
    // ✅ CORRECTO: Usa DELETE /api/tasks/:id
    await apiClient.delete(ApiEndpoints.taskById(id));
  }

  @override
  Future<TaskModel> uploadImage(String taskId, File image) async {
    // ✅ CORRECTO: Usa POST multipart /api/tasks/:id/image
    final response = await apiClient.uploadMultipart(
      ApiEndpoints.uploadImage(taskId),
      image,
      fieldName: 'image', // El backend espera el campo 'image'
    );

    // IMPORTANTE: El backend retorna la tarea dentro de 'data.task'
    return TaskModel.fromJson(response['data']['task']);
  }

  @override
  Future<void> deleteImage(String taskId) async {
    // ✅ CORRECTO: Usa DELETE /api/tasks/:id/image
    await apiClient.delete(ApiEndpoints.deleteImage(taskId));
  }
}
