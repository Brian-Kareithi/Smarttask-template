import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'theme/app_theme.dart';
import 'navigation/app_router.dart';

class SmartTaskApp extends StatefulWidget {
  const SmartTaskApp({super.key});

  @override
  State<SmartTaskApp> createState() => _SmartTaskAppState();
}

class _SmartTaskAppState extends State<SmartTaskApp> {
  late final AppRouter _appRouter;

  @override
  void initState() {
    super.initState();
    _appRouter = AppRouter();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initThemeListener();
    });
  }

  void _initThemeListener() {
    final auth = context.read<AuthProvider>();
    if (auth.isAuthenticated && auth.user != null) {
      context.read<ThemeProvider>().initialize(auth.user!.uid);
    }
    auth.addListener(() {
      if (auth.isAuthenticated && auth.user != null) {
        context.read<ThemeProvider>().initialize(auth.user!.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
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
          routerConfig: _appRouter.router,
        );
      },
    );
  }
}
