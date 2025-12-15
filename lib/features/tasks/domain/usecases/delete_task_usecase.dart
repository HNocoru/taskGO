// ==================== features/tasks/domain/usecases/delete_task_usecase.dart ====================
import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../repositories/task_repository.dart';

class DeleteTaskUseCase {
  final TaskRepository repository;

  DeleteTaskUseCase(this.repository);

  Future<Either<Failure, void>> call(String taskId) async {
    return await repository.deleteTask(taskId);
  }
}
