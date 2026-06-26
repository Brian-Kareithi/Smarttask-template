import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;
  final ValueChanged<bool> onToggleComplete;
  final int index;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggleComplete,
    this.index = 0,
  });

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFFF3B30);
      case 'medium':
        return const Color(0xFFFF9500);
      case 'low':
        return const Color(0xFF34C759);
      default:
        return const Color(0xFF34C759);
    }
  }

  Color _priorityBgColor(String priority) {
    return _priorityColor(priority).withValues(alpha: 0.12);
  }

  Color _categoryColor(String category) {
    final colors = {
      'Personal': const Color(0xFF6C63FF),
      'Work': const Color(0xFFFF6584),
      'Health': const Color(0xFF34C759),
      'Education': const Color(0xFF007AFF),
      'Finance': const Color(0xFFFF9500),
      'Development': const Color(0xFF5856D6),
      'Design': const Color(0xFFFF2D55),
      'Shopping': const Color(0xFF00C7BE),
      'Fitness': const Color(0xFF4CAF50),
    };
    return colors[category] ?? const Color(0xFF8E8E93);
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final priorityColor = _priorityColor(task.priority);
    final catColor = _categoryColor(task.category);

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: 1.0,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 400),
        offset: const Offset(0, 0),
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => onToggleComplete(!task.completed),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: task.completed
                            ? priorityColor
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: task.completed
                              ? priorityColor
                              : priorityColor.withValues(alpha: 0.5),
                          width: 2,
                        ),
                      ),
                      child: task.completed
                          ? const Icon(
                              Icons.check,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            decoration: task.completed
                                ? TextDecoration.lineThrough
                                : null,
                            color: task.completed
                                ? theme.textTheme.bodyMedium?.color
                                : null,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (task.description != null &&
                            task.description!.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            task.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Badge(
                              label: task.priority == 'high'
                                  ? 'High'
                                  : task.priority == 'medium'
                                      ? 'Medium'
                                      : 'Low',
                              bgColor: _priorityBgColor(task.priority),
                              textColor: priorityColor,
                            ),
                            _Badge(
                              label: task.category,
                              bgColor: catColor.withValues(alpha: 0.12),
                              textColor: catColor,
                            ),
                            if (task.progress > 0)
                              _Badge(
                                label: '${task.progress}%',
                                bgColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.12),
                                textColor: theme.colorScheme.primary,
                              ),
                            if (task.collaborators.isNotEmpty)
                              _Badge(
                                label:
                                    '${task.collaborators.length} collab',
                                bgColor: Colors.blue.withValues(alpha: 0.12),
                                textColor: Colors.blue,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(task.createdAt),
                    style: theme.textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color bgColor;
  final Color textColor;

  const _Badge({
    required this.label,
    required this.bgColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
