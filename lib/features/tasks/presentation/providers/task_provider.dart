// ==================== features/tasks/presentation/providers/task_provider.dart ====================
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/create_task_usecase.dart';
import '../../domain/usecases/delete_task_usecase.dart';
import '../../domain/usecases/get_tasks_usecase.dart';
import '../../domain/repositories/task_repository.dart';

enum TaskViewFilter { all, pending, completed }

class TaskProvider extends ChangeNotifier {
  final GetTasksUseCase getTasksUseCase;
  final CreateTaskUseCase createTaskUseCase;
  final DeleteTaskUseCase deleteTaskUseCase;
  final TaskRepository taskRepository;

  List<TaskEntity> _tasks = [];
  List<TaskEntity> _filteredTasks = [];
  bool _isLoading = false;
  String? _errorMessage;
  TaskViewFilter _currentFilter = TaskViewFilter.all;
  String? _priorityFilter;

  TaskProvider({
    required this.getTasksUseCase,
    required this.createTaskUseCase,
    required this.deleteTaskUseCase,
    required this.taskRepository,
  });

  // Getters
  List<TaskEntity> get tasks => _filteredTasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TaskViewFilter get currentFilter => _currentFilter;
  String? get priorityFilter => _priorityFilter;

  int get totalTasks => _tasks.length;
  int get pendingTasks => _tasks.where((t) => !t.completed).length;
  int get completedTasks => _tasks.where((t) => t.completed).length;

  // Load tasks
  Future<void> loadTasks({bool forceRefresh = false}) async {
    if (_isLoading && !forceRefresh) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final result = await getTasksUseCase(
      completed: _getCompletedFilter(),
      priority: _priorityFilter,
    );

    result.fold(
      (failure) {
        _errorMessage = failure.message;
        _isLoading = false;
        notifyListeners();
      },
      (tasks) {
        _tasks = tasks;
        _applyFilter();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Create task
  Future<bool> createTask({
    required String title,
    String? description,
    String? priority,
    DateTime? dueDate,
  }) async {
    final result = await createTaskUseCase(
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (task) {
        _tasks.insert(0, task);
        _applyFilter();
        notifyListeners();
        return true;
      },
    );
  }

  // Update task
  Future<bool> updateTask({
    required String id,
    String? title,
    String? description,
    String? priority,
    DateTime? dueDate,
    bool? completed,
  }) async {
    final result = await taskRepository.updateTask(
      id: id,
      title: title,
      description: description,
      priority: priority,
      dueDate: dueDate,
      completed: completed,
    );

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (task) {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasks[index] = task;
          _applyFilter();
          notifyListeners();
        }
        return true;
      },
    );
  }

  // Complete task
  Future<bool> completeTask(String id) async {
    final result = await taskRepository.completeTask(id);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (task) {
        final index = _tasks.indexWhere((t) => t.id == id);
        if (index != -1) {
          _tasks[index] = task;
          _applyFilter();
          notifyListeners();
        }
        return true;
      },
    );
  }

  // Delete task
  Future<bool> deleteTask(String id) async {
    final result = await deleteTaskUseCase(id);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (_) {
        _tasks.removeWhere((t) => t.id == id);
        _applyFilter();
        notifyListeners();
        return true;
      },
    );
  }

  // Upload image
  Future<bool> uploadImage(String taskId, File image) async {
    final result = await taskRepository.uploadImage(taskId, image);

    return result.fold(
      (failure) {
        _errorMessage = failure.message;
        notifyListeners();
        return false;
      },
      (task) {
        final index = _tasks.indexWhere((t) => t.id == taskId);
        if (index != -1) {
          _tasks[index] = task;
          _applyFilter();
          notifyListeners();
        }
        return true;
      },
    );
  }

  // Set filter
  void setFilter(TaskViewFilter filter) {
    _currentFilter = filter;
    _applyFilter();
    notifyListeners();
  }

  // Set priority filter
  void setPriorityFilter(String? priority) {
    _priorityFilter = priority;
    loadTasks(forceRefresh: true);
  }

  // Apply filter
  void _applyFilter() {
    switch (_currentFilter) {
      case TaskViewFilter.all:
        _filteredTasks = _tasks;
        break;
      case TaskViewFilter.pending:
        _filteredTasks = _tasks.where((t) => !t.completed).toList();
        break;
      case TaskViewFilter.completed:
        _filteredTasks = _tasks.where((t) => t.completed).toList();
        break;
    }
  }

  bool? _getCompletedFilter() {
    switch (_currentFilter) {
      case TaskViewFilter.pending:
        return false;
      case TaskViewFilter.completed:
        return true;
      default:
        return null;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
