import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskDetailSheet extends StatefulWidget {
  final Task task;

  const TaskDetailSheet({super.key, required this.task});

  static void show(BuildContext context, Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => TaskDetailSheet(task: task),
    );
  }

  @override
  State<TaskDetailSheet> createState() => _TaskDetailSheetState();
}

class _TaskDetailSheetState extends State<TaskDetailSheet> {
  late double _progress;
  final _collabController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _progress = widget.task.progress.toDouble();
  }

  @override
  void dispose() {
    _collabController.dispose();
    super.dispose();
  }

  Color _priorityColor(String p) {
    switch (p) {
      case 'high':
        return const Color(0xFFFF3B30);
      case 'medium':
        return const Color(0xFFFF9500);
      default:
        return const Color(0xFF34C759);
    }
  }

  String _formatDate(DateTime d) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[d.month - 1]} ${d.day}, ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final task = widget.task;
    final pColor = _priorityColor(task.priority);
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 12, 24, 16 + bottomInset),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Task Details',
                      style: theme.textTheme.headlineMedium),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: const Color(0xFFFF3B30),
                  onPressed: _confirmDelete,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(task.title,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                )),
            if (task.description != null &&
                task.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(task.description!,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodyMedium?.color,
                  )),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                _BadgeChip(
                    label: task.priority == 'high'
                        ? 'High'
                        : task.priority == 'medium'
                            ? 'Medium'
                            : 'Low',
                    color: pColor),
                const SizedBox(width: 8),
                _BadgeChip(label: task.category, color: pColor),
              ],
            ),
            const SizedBox(height: 16),
            Text('Progress', style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _progress,
                    min: 0,
                    max: 100,
                    divisions: 4,
                    label: '${_progress.round()}%',
                    onChanged: (v) {
                      setState(() => _progress = v.round().toDouble());
                      context
                          .read<TaskProvider>()
                          .updateProgress(task.id, v.round());
                    },
                  ),
                ),
                Text('${_progress.round()}%',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    )),
              ],
            ),
            const SizedBox(height: 8),
            Text('Created: ${_formatDate(task.createdAt)}',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context
                      .read<TaskProvider>()
                      .toggleComplete(task.id, !task.completed);
                },
                icon: Icon(task.completed
                    ? Icons.unfold_more
                    : Icons.check_circle_outline),
                label: Text(task.completed ? 'Reopen' : 'Mark Complete'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: task.completed
                      ? Colors.orange
                      : const Color(0xFF34C759),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Collaborators',
                style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            ...task.collaborators
                .map((uid) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(uid, style: theme.textTheme.bodyMedium),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline,
                            color: Color(0xFFFF3B30)),
                        onPressed: () {
                          context
                              .read<TaskProvider>()
                              .removeCollaborator(task.id, uid);
                        },
                      ),
                    )),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _collabController,
                    decoration: InputDecoration(
                      hintText: 'Enter email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () {
                    if (_collabController.text.trim().isNotEmpty) {
                      context
                          .read<TaskProvider>()
                          .addCollaborator(
                              task.id, _collabController.text.trim());
                      _collabController.clear();
                    }
                  },
                  icon: const Icon(Icons.person_add),
                  color: theme.colorScheme.primary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Task'),
        content:
            const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<TaskProvider>().deleteTask(widget.task.id);
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFFF3B30)),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
