import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String? description;
  final bool completed;
  final int progress;
  final String priority;
  final String category;
  final DateTime? dueDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String userId;
  final List<String> collaborators;

  Task({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.progress = 0,
    this.priority = 'low',
    this.category = 'Personal',
    this.dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    required this.userId,
    this.collaborators = const [],
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory Task.fromFirestore(Map<String, dynamic> data, String id) {
    return Task(
      id: id,
      title: data['title'] ?? '',
      description: data['description'],
      completed: data['completed'] ?? false,
      progress: data['progress'] ?? 0,
      priority: data['priority'] ?? 'low',
      category: data['category'] ?? 'Personal',
      dueDate: (data['dueDate'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userId: data['userId'] ?? '',
      collaborators: List<String>.from(data['collaborators'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'completed': completed,
      'progress': progress,
      'priority': priority,
      'category': category,
      'dueDate': dueDate != null ? Timestamp.fromDate(dueDate!) : null,
      'userId': userId,
      'collaborators': collaborators,
    };
  }

  Task copyWith({
    String? id,
    String? title,
    String? description,
    bool? completed,
    int? progress,
    String? priority,
    String? category,
    DateTime? dueDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userId,
    List<String>? collaborators,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      progress: progress ?? this.progress,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userId: userId ?? this.userId,
      collaborators: collaborators ?? this.collaborators,
    );
  }
}
