// ==================== features/tasks/presentation/pages/create_task_page.dart ====================
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:provider/provider.dart';
import 'package:taskgo/core/utils/constants.dart';
import 'package:taskgo/core/utils/helpers.dart';
import 'package:taskgo/features/tasks/domain/entities/task_entity.dart';
import 'package:taskgo/features/tasks/presentation/providers/task_provider.dart';

import '../../../auth/presentation/widgets/auth_widgets.dart';

class CreateTaskPage extends StatefulWidget {
  final TaskEntity? task; // Para edición

  const CreateTaskPage({super.key, this.task});

  @override
  State<CreateTaskPage> createState() => _CreateTaskPageState();
}

class _CreateTaskPageState extends State<CreateTaskPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String _selectedPriority = 'medium';
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedPriority = widget.task!.priority;
      _selectedDate = widget.task!.dueDate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final taskProvider = context.read<TaskProvider>();
    final isEdit = widget.task != null;

    final success = isEdit
        ? await taskProvider.updateTask(
            id: widget.task!.id,
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            dueDate: _selectedDate,
          )
        : await taskProvider.createTask(
            title: _titleController.text.trim(),
            description: _descriptionController.text.trim(),
            priority: _selectedPriority,
            dueDate: _selectedDate,
          );

    if (!mounted) return;

    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEdit ? 'Tarea actualizada' : 'Tarea creada',
          ),
          backgroundColor: AppConstants.successColor,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            taskProvider.errorMessage ?? 'Error al guardar tarea',
          ),
          backgroundColor: AppConstants.errorColor,
        ),
      );
    }
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDate = date;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.task != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Editar Tarea' : 'Nueva Tarea'),
        backgroundColor: AppConstants.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: AppConstants.screenPadding,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              CustomTextField(
                controller: _titleController,
                label: 'Título',
                hint: 'Ej: Comprar víveres',
                prefixIcon: Icons.title,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es requerido';
                  }
                  if (value.length > 100) {
                    return 'Máximo 100 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Descripción (opcional)',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Agrega detalles adicionales...',
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: BorderSide(color: Colors.grey[200]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.borderRadius),
                        borderSide: const BorderSide(
                          color: AppConstants.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Priority
              const Text(
                'Prioridad',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _PriorityChip(
                    label: 'Baja',
                    value: 'low',
                    selectedValue: _selectedPriority,
                    color: AppConstants.lowPriorityColor,
                    onSelected: (value) {
                      setState(() => _selectedPriority = value);
                    },
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Media',
                    value: 'medium',
                    selectedValue: _selectedPriority,
                    color: AppConstants.mediumPriorityColor,
                    onSelected: (value) {
                      setState(() => _selectedPriority = value);
                    },
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Alta',
                    value: 'high',
                    selectedValue: _selectedPriority,
                    color: AppConstants.highPriorityColor,
                    onSelected: (value) {
                      setState(() => _selectedPriority = value);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Due date
              const Text(
                'Fecha límite (opcional)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppConstants.textPrimaryColor,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!),
                    borderRadius:
                        BorderRadius.circular(AppConstants.borderRadius),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppConstants.primaryColor),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate != null
                            ? Helpers.formatDate(_selectedDate!)
                            : 'Seleccionar fecha',
                        style: TextStyle(
                          fontSize: 16,
                          color: _selectedDate != null
                              ? AppConstants.textPrimaryColor
                              : AppConstants.textSecondaryColor,
                        ),
                      ),
                      const Spacer(),
                      if (_selectedDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () {
                            setState(() => _selectedDate = null);
                          },
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Save button
              GradientButton(
                text: isEdit ? 'Guardar Cambios' : 'Crear Tarea',
                onPressed: _handleSave,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final String value;
  final String selectedValue;
  final Color color;
  final ValueChanged<String> onSelected;

  const _PriorityChip({
    required this.label,
    required this.value,
    required this.selectedValue,
    required this.color,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return Expanded(
      child: GestureDetector(
        onTap: () => onSelected(value),
        child: AnimatedContainer(
          duration: AppConstants.animationDuration,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
