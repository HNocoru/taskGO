// ==================== features/tasks/domain/repositories/task_repository.dart ====================
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    bool? completed,
    String? priority,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, TaskEntity>> getTaskById(String id);

  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  });

  Future<Either<Failure, TaskEntity>> updateTask({
    required String id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? completed,
  });

  Future<Either<Failure, TaskEntity>> completeTask(String id);

  Future<Either<Failure, void>> deleteTask(String id);

  Future<Either<Failure, TaskEntity>> uploadImage(String taskId, File image);

  Future<Either<Failure, void>> deleteImage(String taskId);
}
