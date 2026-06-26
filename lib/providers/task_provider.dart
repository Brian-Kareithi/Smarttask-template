import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  StreamSubscription? _subscription;
  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _error;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void startListening(String userId) {
    _subscription?.cancel();
    _isLoading = true;
    notifyListeners();

    _subscription = _taskService.streamTasks(userId).listen(
      (tasks) {
        _tasks = tasks;
        _isLoading = false;
        notifyListeners();
      },
      onError: (err) {
        _error = err.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  List<Task> filteredTasks({String? search, String? filter}) {
    List<Task> result = List.from(_tasks);

    if (search != null && search.isNotEmpty) {
      final query = search.toLowerCase();
      result = result.where((t) =>
        t.title.toLowerCase().contains(query) ||
        (t.description?.toLowerCase().contains(query) ?? false)
      ).toList();
    }

    switch (filter) {
      case 'Active':
        result = result.where((t) => !t.completed).toList();
        break;
      case 'Completed':
        result = result.where((t) => t.completed).toList();
        break;
      case 'High Priority':
        result = result.where((t) => t.priority == 'high').toList();
        break;
      case 'Today':
        break;
    }

    return result;
  }

  int get completedCount => _tasks.where((t) => t.completed).length;
  int get totalCount => _tasks.length;
  int get pendingCount => _tasks.where((t) => !t.completed).length;
  int get highPriorityCount =>
      _tasks.where((t) => !t.completed && t.priority == 'high').length;
  double get completionPercentage =>
      totalCount > 0 ? (completedCount / totalCount) * 100 : 0;
  List<Task> get recentTasks =>
      _tasks.where((t) => !t.completed).take(5).toList();
  List<Task> get allTasks => _tasks;

  Map<String, int> get categoryDistribution {
    final map = <String, int>{};
    for (final task in _tasks) {
      map[task.category] = (map[task.category] ?? 0) + 1;
    }
    return map;
  }

  Future<void> createTask(Task task) async {
    try {
      await _taskService.createTask(task);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateTask(String id, Map<String, dynamic> data) async {
    try {
      await _taskService.updateTask(id, data);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    try {
      await _taskService.deleteTask(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleComplete(String id, bool completed) async {
    await updateTask(id, {'completed': completed});
  }

  Future<void> updateProgress(String id, int progress) async {
    await updateTask(id, {'progress': progress});
  }

  Future<void> addCollaborator(String taskId, String email) async {
    try {
      await _taskService.addCollaborator(taskId, email);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeCollaborator(String taskId, String uid) async {
    try {
      await _taskService.removeCollaborator(taskId, uid);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}
