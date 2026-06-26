import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase/config.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/stats_provider.dart';
import 'providers/task_provider.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FirebaseConfig.initialize();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => StatsProvider()),
      ],
      child: const SmartTaskApp(),
    ),
  );
}
