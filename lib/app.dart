import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';

final _router = AppRouter().router;

class SmartTaskApp extends StatelessWidget {
  const SmartTaskApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'SmartTask',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.isLoading
          ? ThemeMode.system
          : themeProvider.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
      routerConfig: _router,
    );
  }
}
