// ==================== features/tasks/domain/usecases/create_task_usecase.dart ====================
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class CreateTaskUseCase {
  final TaskRepository repository;

  CreateTaskUseCase(this.repository);

  Future<Either<Failure, TaskEntity>> call({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    return await repository.createTask(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );
  }
}
