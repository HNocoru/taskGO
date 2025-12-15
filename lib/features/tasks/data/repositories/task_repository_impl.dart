// ==================== features/tasks/data/repositories/task_repository_impl.dart ====================
import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDataSource remoteDataSource;

  TaskRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<TaskEntity>>> getTasks({
    bool? completed,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final tasks = await remoteDataSource.getTasks(
        completed: completed,
        priority: priority,
        page: page,
        limit: limit,
      );
      return Right(tasks.map((task) => task.toEntity()).toList());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> getTaskById(String id) async {
    try {
      final task = await remoteDataSource.getTaskById(id);
      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    try {
      final task = await remoteDataSource.createTask(
        title: title,
        description: description,
        priority: priority,
        dueDate: dueDate,
      );
      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> updateTask({
    required String id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? completed,
  }) async {
    try {
      // ✅ CONSTRUIR el Map de updates solo con los campos que no son null
      final updates = <String, dynamic>{};

      if (title != null) updates['title'] = title;
      if (description != null) updates['description'] = description;
      if (priority != null) updates['priority'] = priority;
      if (dueDate != null) updates['dueDate'] = dueDate.toIso8601String();
      if (completed != null) updates['completed'] = completed;

      // ✅ LLAMAR al datasource con el Map de updates
      // Esto se acopla con PATCH /api/tasks/:id del backend
      final task = await remoteDataSource.updateTask(
        id: id,
        updates: updates,
      );

      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> completeTask(String id) async {
    try {
      final task = await remoteDataSource.completeTask(id);
      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTask(String id) async {
    try {
      await remoteDataSource.deleteTask(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, TaskEntity>> uploadImage(
    String taskId,
    File image,
  ) async {
    try {
      final task = await remoteDataSource.uploadImage(taskId, image);
      return Right(task.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteImage(String taskId) async {
    try {
      await remoteDataSource.deleteImage(taskId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Error inesperado: $e'));
    }
  }
}
