import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../providers/stats_provider.dart';
import '../providers/task_provider.dart';
import '../widgets/auth_modal.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthProvider>();
      if (auth.isAuthenticated && auth.user != null) {
        context.read<StatsProvider>().startListening(auth.user!.uid);
        context.read<ThemeProvider>().initialize(auth.user!.uid);
      }
    });
  }

  void _editProfile() {
    final controller = TextEditingController(
      text: context.read<AuthProvider>().user?.displayName ?? '',
    );
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(
            24, 12, 24, 16 + MediaQuery.of(ctx).viewInsets.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(ctx)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('Edit Profile',
                style: Theme.of(ctx).textTheme.headlineMedium),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                labelText: 'Display Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  context
                      .read<AuthProvider>()
                      .updateDisplayName(controller.text.trim());
                  Navigator.of(ctx).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(ctx).colorScheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<AuthProvider>().signOut();
              context.read<TaskProvider>().stopListening();
              Navigator.of(ctx).pop();
              context.go('/auth');
            },
            style: TextButton.styleFrom(
                foregroundColor: const Color(0xFFFF3B30)),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = context.watch<AuthProvider>();
    final statsProvider = context.watch<StatsProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    final user = auth.user;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final initial = displayName.isNotEmpty
        ? displayName[0].toUpperCase()
        : 'U';
    final joinedDate = user?.metadata.creationTime != null
        ? DateFormat('MMM yyyy').format(user!.metadata.creationTime!)
        : 'Recent';

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 44,
                backgroundColor:
                    theme.colorScheme.primary.withValues(alpha: 0.15),
                child: Text(
                  initial,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Text(displayName, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 4),
              Text(email, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 4),
              Text('Joined $joinedDate',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12,
                  )),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF34C759).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.verified,
                        size: 14, color: Color(0xFF34C759)),
                    SizedBox(width: 4),
                    Text('Verified',
                        style: TextStyle(
                          color: Color(0xFF34C759),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  _ProfileStat(
                    value: '${statsProvider.stats.tasksCompleted}',
                    label: 'Tasks Done',
                  ),
                  _ProfileStat(
                    value:
                        '${statsProvider.stats.productivity.round()}%',
                    label: 'Productivity',
                  ),
                  _ProfileStat(
                    value: '${statsProvider.stats.projects}',
                    label: 'Projects',
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      trailing: Switch(
                        value: true,
                        onChanged: (_) {},
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.dark_mode_outlined,
                      title: 'Dark Mode',
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (v) {
                          if (auth.user != null) {
                            themeProvider.toggleDarkMode(
                                auth.user!.uid, v);
                          }
                        },
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.fingerprint,
                      title: 'Biometric Login',
                      trailing: Switch(
                        value: false,
                        onChanged: (_) {},
                        activeColor: theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Card(
                child: Column(
                  children: [
                    _SettingsTile(
                      icon: Icons.shield_outlined,
                      title: 'Privacy & Security',
                      onTap: () => AuthModal.show(
                        context,
                        'Privacy & Security',
                        'Your data is securely stored and encrypted. '
                            'We use industry-standard security measures '
                            'to protect your personal information. '
                            'Your tasks and preferences are private '
                            'and accessible only to you and authorized collaborators.',
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.help_outline,
                      title: 'Help & Support',
                      onTap: () => AuthModal.show(
                        context,
                        'Help & Support',
                        'Getting Started:\nCreate tasks, set priorities, '
                            'and track your progress.\n\n'
                            'Task Management:\nSwipe to complete, tap to edit, '
                            'use categories to organize.\n\n'
                            'Collaboration:\nAdd collaborators by email to '
                            'work on tasks together.',
                      ),
                    ),
                    const Divider(height: 1, indent: 56),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      title: 'Terms & Conditions',
                      onTap: () => AuthModal.show(
                        context,
                        'Terms & Conditions',
                        'Account Terms:\nYou are responsible for maintaining '
                            'the confidentiality of your account.\n\n'
                            'Acceptable Use:\nUse the app responsibly and '
                            'respect other users.\n\n'
                            'Service Availability:\nWe strive for 99.9% uptime '
                            'but cannot guarantee uninterrupted service.\n\n'
                            'Subscription:\nBasic features are free. Premium '
                            'features may require a subscription.',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _editProfile,
                  icon: const Icon(Icons.edit_outlined),
                  label: const Text('Edit Profile'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.colorScheme.primary,
                    side: BorderSide(color: theme.colorScheme.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _logout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Logout'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF3B30),
                    side: const BorderSide(color: Color(0xFFFF3B30)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String value;
  final String label;

  const _ProfileStat({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              )),
          const SizedBox(height: 2),
          Text(label, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: theme.colorScheme.primary),
      title: Text(title, style: theme.textTheme.titleMedium),
      trailing: trailing ?? (onTap != null
          ? const Icon(Icons.chevron_right)
          : null),
      onTap: onTap,
    );
  }
}
