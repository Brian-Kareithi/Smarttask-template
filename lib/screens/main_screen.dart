import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/task_provider.dart';
import '../providers/stats_provider.dart';
import '../widgets/stat_card.dart';
import '../widgets/progress_bar.dart';
import '../widgets/task_card.dart';
import '../widgets/task_detail_sheet.dart';
import '../widgets/empty_state.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _showPieChart = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.user != null) {
        context.read<TaskProvider>().startListening(auth.user!.uid);
        context.read<StatsProvider>().startListening(auth.user!.uid);
      }
    });
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour >= 5 && hour < 12) return 'Good Morning';
    if (hour >= 12 && hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _firstName() {
    final auth = context.read<AuthProvider>();
    final name = auth.user?.displayName ?? 'User';
    return name.split(' ').first;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final taskProvider = context.watch<TaskProvider>();
    final statsProvider = context.watch<StatsProvider>();
    final now = DateTime.now();
    final dateStr = DateFormat('EEEE, MMMM d').format(now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _greeting(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      Text(
                        _firstName(),
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: () => context.go('/profile'),
                    icon: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withValues(alpha: 0.1),
                      child: Icon(
                        Icons.person,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(dateStr, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Your Progress',
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        '${taskProvider.completionPercentage.round()}%',
                        style: theme.textTheme.headlineLarge?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ProgressBar(
                        progress: taskProvider.completionPercentage,
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.2,
                children: [
                  StatCard(
                    icon: Icons.check_circle_outline,
                    label: 'Completed',
                    value: '${taskProvider.completedCount}',
                    color: const Color(0xFF34C759),
                  ),
                  StatCard(
                    icon: Icons.flag_outlined,
                    label: 'High Priority',
                    value: '${taskProvider.highPriorityCount}',
                    color: const Color(0xFFFF3B30),
                  ),
                  StatCard(
                    icon: Icons.today_outlined,
                    label: "Today's Tasks",
                    value: '${taskProvider.totalCount}',
                    color: const Color(0xFF007AFF),
                  ),
                  StatCard(
                    icon: Icons.trending_up,
                    label: 'Progress',
                    value: '${taskProvider.completionPercentage.round()}%',
                    color: theme.colorScheme.primary,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Analytics', style: theme.textTheme.titleLarge),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Line')),
                      ButtonSegment(value: true, label: Text('Pie')),
                    ],
                    selected: {_showPieChart},
                    onSelectionChanged: (v) =>
                        setState(() => _showPieChart = v.first),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 200,
                child: _showPieChart
                    ? _PieChartWidget(taskProvider: taskProvider)
                    : _LineChartWidget(),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Recent Tasks', style: theme.textTheme.titleLarge),
                  TextButton(
                    onPressed: () => context.go('/tasks'),
                    child: const Text('See All'),
                  ),
                ],
              ),
              taskProvider.recentTasks.isEmpty
                  ? EmptyState(
                      icon: Icons.task_alt,
                      title: 'No tasks yet. Create your first task!',
                      actionLabel: 'Go to Tasks',
                      onAction: () => context.go('/tasks'),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: taskProvider.recentTasks.length,
                      itemBuilder: (context, index) {
                        final task = taskProvider.recentTasks[index];
                        return TaskCard(
                          task: task,
                          index: index,
                          onTap: () =>
                              TaskDetailSheet.show(context, task),
                          onToggleComplete: (v) => taskProvider
                              .toggleComplete(task.id, v),
                        );
                      },
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LineChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final data = [20.0, 45.0, 28.0, 80.0, 99.0, 43.0, 50.0];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Productivity', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: theme.dividerTheme.color ?? const Color(0xFFE8ECF0),
                      strokeWidth: 1,
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                          final idx = value.toInt();
                          if (idx >= 0 && idx < days.length) {
                            return Text(days[idx],
                                style: const TextStyle(fontSize: 10));
                          }
                          return const Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  minX: 0,
                  maxX: 6,
                  minY: 0,
                  maxY: 100,
                  lineBarsData: [
                    LineChartBarData(
                      spots: List.generate(data.length,
                          (i) => FlSpot(i.toDouble(), data[i])),
                      isCurved: true,
                      color: theme.colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PieChartWidget extends StatelessWidget {
  final TaskProvider taskProvider;

  const _PieChartWidget({required this.taskProvider});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dist = taskProvider.categoryDistribution;

    if (dist.isEmpty) {
      return Card(
        child: Center(
          child: Text('No data',
              style: theme.textTheme.bodyMedium),
        ),
      );
    }

    final colors = [
      const Color(0xFF6C63FF),
      const Color(0xFFFF6584),
      const Color(0xFF34C759),
      const Color(0xFF007AFF),
      const Color(0xFFFF9500),
      const Color(0xFF5856D6),
      const Color(0xFFFF2D55),
      const Color(0xFF00C7BE),
      const Color(0xFF4CAF50),
    ];

    final entries = dist.entries.toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Categories', style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 30,
                        sections: List.generate(entries.length, (i) {
                          final total = entries.fold<int>(
                              0, (sum, e) => sum + e.value);
                          return PieChartSectionData(
                            color: colors[i % colors.length],
                            value: total > 0
                                ? (entries[i].value / total) * 100
                                : 0,
                            title: '',
                            radius: 30,
                          );
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(
                      entries.length > 5 ? 5 : entries.length,
                      (i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: colors[i % colors.length],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(entries[i].key,
                                style: const TextStyle(fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
