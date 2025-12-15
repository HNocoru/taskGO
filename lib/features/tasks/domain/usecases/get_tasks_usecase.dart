// ==================== features/tasks/domain/usecases/get_tasks_usecase.dart ====================
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/task_entity.dart';
import '../repositories/task_repository.dart';

class GetTasksUseCase {
  final TaskRepository repository;

  GetTasksUseCase(this.repository);

  Future<Either<Failure, List<TaskEntity>>> call({
    bool? completed,
    String? priority,
    int page = 1,
    int limit = 20,
  }) async {
    return await repository.getTasks(
      completed: completed,
      priority: priority,
      page: page,
      limit: limit,
    );
  }
}
