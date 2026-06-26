import 'package:cloud_firestore/cloud_firestore.dart';

class Stats {
  final int tasksCompleted;
  final double productivity;
  final int projects;
  final DateTime? lastUpdated;

  Stats({
    this.tasksCompleted = 0,
    this.productivity = 0.0,
    this.projects = 0,
    this.lastUpdated,
  });

  factory Stats.fromFirestore(Map<String, dynamic> data) {
    return Stats(
      tasksCompleted: data['tasksCompleted'] ?? 0,
      productivity: (data['productivity'] ?? 0.0).toDouble(),
      projects: data['projects'] ?? 0,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tasksCompleted': tasksCompleted,
      'productivity': productivity,
      'projects': projects,
    };
  }

  Stats copyWith({
    int? tasksCompleted,
    double? productivity,
    int? projects,
    DateTime? lastUpdated,
  }) {
    return Stats(
      tasksCompleted: tasksCompleted ?? this.tasksCompleted,
      productivity: productivity ?? this.productivity,
      projects: projects ?? this.projects,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}
