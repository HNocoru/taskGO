// ==================== features/tasks/domain/entities/task_entity.dart ====================
class TaskEntity {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final String priority; // low, medium, high
  final DateTime? dueDate;
  final String? imageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    required this.completed,
    required this.priority,
    this.dueDate,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });
}
