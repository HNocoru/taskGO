// ==================== features/tasks/presentation/widgets/task_widgets.dart ====================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/task_entity.dart';
import '../providers/task_provider.dart';
import '../pages/task_detail_page.dart';

class TaskList extends StatelessWidget {
  final List<TaskEntity> tasks;
  
  const TaskList({super.key, required this.tasks});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return TaskCard(
          task: task,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => TaskDetailPage(task: task),
              ),
            );
          },
        );
      },
    );
  }
}

class TaskCard extends StatelessWidget {
  final TaskEntity task;
  final VoidCallback onTap;
  
  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
  });
  
  Color _getPriorityColor() {
    switch (task.priority) {
      case 'high':
        return AppConstants.highPriorityColor;
      case 'medium':
        return AppConstants.mediumPriorityColor;
      case 'low':
        return AppConstants.lowPriorityColor;
      default:
        return AppConstants.mediumPriorityColor;
    }
  }
  
  IconData _getPriorityIcon() {
    switch (task.priority) {
      case 'high':
        return Icons.arrow_upward;
      case 'medium':
        return Icons.drag_handle;
      case 'low':
        return Icons.arrow_downward;
      default:
        return Icons.drag_handle;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final taskProvider = context.read<TaskProvider>();
    
    return Dismissible(
      key: Key(task.id),
      background: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppConstants.errorColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        taskProvider.deleteTask(task.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tarea eliminada')),
        );
      },
      child: AnimatedContainer(
        duration: AppConstants.animationDuration,
        curve: AppConstants.animationCurve,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Checkbox
                  GestureDetector(
                    onTap: () {
                      taskProvider.completeTask(task.id);
                    },
                    child: AnimatedContainer(
                      duration: AppConstants.animationDuration,
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.completed
                            ? AppConstants.successColor
                            : Colors.transparent,
                        border: Border.all(
                          color: task.completed
                              ? AppConstants.successColor
                              : Colors.grey[400]!,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: task.completed
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 16,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  
                  // Task info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: task.completed
                                ? AppConstants.textSecondaryColor
                                : AppConstants.textPrimaryColor,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            task.description!,
                            style: TextStyle(
                              fontSize: 14,
                              color: AppConstants.textSecondaryColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        if (task.dueDate != null) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 14,
                                color: _isOverdue()
                                    ? AppConstants.errorColor
                                    : AppConstants.textSecondaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                Helpers.getRelativeDate(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: _isOverdue()
                                      ? AppConstants.errorColor
                                      : AppConstants.textSecondaryColor,
                                  fontWeight: _isOverdue()
                                      ? FontWeight.w600
                                      : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  
                  // Priority indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getPriorityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getPriorityIcon(),
                          size: 14,
                          color: _getPriorityColor(),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          Helpers.capitalize(task.priority),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: _getPriorityColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  bool _isOverdue() {
    if (task.dueDate == null || task.completed) return false;
    return task.dueDate!.isBefore(DateTime.now());
  }
}

class StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  
  const StatCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}

class EmptyTasksWidget extends StatelessWidget {
  const EmptyTasksWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.task_alt,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No hay tareas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppConstants.textSecondaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Crea una nueva tarea para empezar',
            style: TextStyle(
              fontSize: 14,
              color: AppConstants.textSecondaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
