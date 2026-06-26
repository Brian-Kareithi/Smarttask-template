import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/add_task_sheet.dart';
import '../widgets/empty_state.dart';
import '../widgets/progress_bar.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  final _searchController = TextEditingController();
  String _selectedFilter = 'All';
  String _searchQuery = '';

  final List<String> _filters = [
    'All',
    'Active',
    'Completed',
    'High Priority',
    'Today',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.user != null) {
        context.read<TaskProvider>().startListening(auth.user!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final filtered = taskProvider.filteredTasks(
      search: _searchQuery,
      filter: _selectedFilter == 'All' ? null : _selectedFilter,
    );

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final auth = context.read<AuthProvider>();
            if (auth.isAuthenticated && auth.user != null) {
              context.read<TaskProvider>().startListening(auth.user!.uid);
            }
          },
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('SmartTask',
                              style: theme.textTheme.headlineLarge),
                          IconButton(
                            onPressed: () => {},
                            style: IconButton.styleFrom(
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                            ),
                            icon: Icon(Icons.person,
                                color: theme.colorScheme.primary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.cardTheme.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${taskProvider.completedCount} tasks completed out of ${taskProvider.totalCount}',
                              style: theme.textTheme.bodyMedium,
                            ),
                            const SizedBox(height: 8),
                            ProgressBar(
                              progress: taskProvider.completionPercentage,
                              height: 8,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _StatChip(
                              label: 'Total',
                              value: '${taskProvider.totalCount}',
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'Completed',
                              value: '${taskProvider.completedCount}',
                              color: const Color(0xFF34C759),
                            ),
                            const SizedBox(width: 8),
                            _StatChip(
                              label: 'Pending',
                              value: '${taskProvider.pendingCount}',
                              color: const Color(0xFFFF9500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _searchController,
                        onChanged: (v) =>
                            setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'Search tasks...',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _searchQuery = '');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: theme.brightness == Brightness.light
                              ? const Color(0xFFF5F7FA)
                              : const Color(0xFF0A0F1C),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 36,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _filters.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final f = _filters[index];
                            final isSelected = _selectedFilter == f;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedFilter = f),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? theme.colorScheme.primary
                                      : theme.brightness == Brightness.light
                                          ? const Color(0xFFF5F7FA)
                                          : const Color(0xFF0A0F1C),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  f,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : theme.textTheme.bodyMedium?.color,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.normal,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              ),
              if (taskProvider.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  child: EmptyState(
                    icon: Icons.search_off,
                    title: _searchQuery.isNotEmpty
                        ? 'No tasks matching your search'
                        : 'No tasks yet — tap + to create one',
                    actionLabel:
                        _searchQuery.isNotEmpty ? null : 'Add Task',
                    onAction: _searchQuery.isNotEmpty
                        ? null
                        : () => AddTaskSheet.show(context),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = filtered[index];
                      return TaskCard(
                        task: task,
                        index: index,
                        onTap: () => TaskDetailSheet.show(context, task),
                        onToggleComplete: (v) =>
                            taskProvider.toggleComplete(task.id, v),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddTaskSheet.show(context),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: color,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
