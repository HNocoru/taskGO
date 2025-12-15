// ==================== features/tasks/presentation/pages/task_detail_page.dart ====================
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/helpers.dart';
import '../../domain/entities/task_entity.dart';
import '../../../auth/presentation/widgets/auth_widgets.dart';
import '../providers/task_provider.dart';
import 'create_task_page.dart';

class TaskDetailPage extends StatelessWidget {
  final TaskEntity task;

  const TaskDetailPage({super.key, required this.task});

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

  Future<void> _pickAndUploadImage(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final taskProvider = context.read<TaskProvider>();
      final file = File(pickedFile.path);

      final success = await taskProvider.uploadImage(task.id, file);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Imagen subida' : 'Error al subir imagen'),
            backgroundColor: success
                ? AppConstants.successColor
                : AppConstants.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _deleteTask(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro de eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppConstants.errorColor,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      final taskProvider = context.read<TaskProvider>();
      final success = await taskProvider.deleteTask(task.id);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarea eliminada'),
              backgroundColor: AppConstants.successColor,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(taskProvider.errorMessage ?? 'Error al eliminar'),
              backgroundColor: AppConstants.errorColor,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: _getPriorityColor(),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CreateTaskPage(task: task),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTask(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                task.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _getPriorityColor(),
                      _getPriorityColor().withOpacity(0.7),
                    ],
                  ),
                ),
                child: task.imageUrl != null
                    ? Image.network(task.imageUrl!, fit: BoxFit.cover)
                    : const Center(
                        child: Icon(
                          Icons.task_alt,
                          size: 80,
                          color: Colors.white54,
                        ),
                      ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: AppConstants.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),

                  // Status and Priority
                  Row(
                    children: [
                      _InfoChip(
                        icon: task.completed
                            ? Icons.check_circle
                            : Icons.pending_actions,
                        label: task.completed ? 'Completada' : 'Pendiente',
                        color: task.completed
                            ? AppConstants.successColor
                            : AppConstants.warningColor,
                      ),
                      const SizedBox(width: 8),
                      _InfoChip(
                        icon: Icons.flag,
                        label: Helpers.capitalize(task.priority),
                        color: _getPriorityColor(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Description
                  if (task.description != null &&
                      task.description!.isNotEmpty) ...[
                    const Text(
                      'Descripción',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        task.description!,
                        style: TextStyle(
                          fontSize: 16,
                          color: AppConstants.textSecondaryColor,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Due date
                  if (task.dueDate != null) ...[
                    const Text(
                      'Fecha límite',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.textPrimaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(
                          AppConstants.borderRadius,
                        ),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            color: AppConstants.primaryColor,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                Helpers.formatDate(task.dueDate!),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppConstants.textPrimaryColor,
                                ),
                              ),
                              Text(
                                Helpers.getRelativeDate(task.dueDate!),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppConstants.textSecondaryColor,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Image section
                  const Text(
                    'Imagen',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  task.imageUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(
                            AppConstants.borderRadius,
                          ),
                          child: Image.network(
                            task.imageUrl!,
                            width: double.infinity,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        )
                      : GestureDetector(
                          onTap: () => _pickAndUploadImage(context),
                          child: Container(
                            width: double.infinity,
                            height: 150,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(
                                AppConstants.borderRadius,
                              ),
                              border: Border.all(
                                color: Colors.grey[300]!,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_photo_alternate,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Agregar imagen',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                  const SizedBox(height: 24),

                  // Complete button
                  if (!task.completed)
                    GradientButton(
                      text: 'Marcar como completada',
                      onPressed: () async {
                        final taskProvider = context.read<TaskProvider>();
                        final success = await taskProvider.completeTask(
                          task.id,
                        );

                        if (context.mounted && success) {
                          Navigator.pop(context);
                        }
                      },
                      gradient: const LinearGradient(
                        colors: [AppConstants.successColor, Color(0xFF059669)],
                      ),
                    ),

                  const SizedBox(height: 32),

                  // Metadata
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(
                        AppConstants.borderRadius,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _MetadataRow(
                          label: 'Creada',
                          value: Helpers.formatDateTime(task.createdAt),
                        ),
                        const SizedBox(height: 8),
                        _MetadataRow(
                          label: 'Actualizada',
                          value: Helpers.formatDateTime(task.updatedAt),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetadataRow extends StatelessWidget {
  final String label;
  final String value;

  const _MetadataRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppConstants.textSecondaryColor,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppConstants.textPrimaryColor,
          ),
        ),
      ],
    );
  }
}
