import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/auth_screen.dart';
import '../screens/login_screen.dart';
import '../screens/signup_screen.dart';
import '../screens/main_screen.dart';
import '../screens/tasks_screen.dart';
import '../screens/profile_screen.dart';
import '../navigation/app_tabs.dart';

class AppRouter {
  final GoRouter router;

  AppRouter()
      : router = GoRouter(
          initialLocation: '/auth',
          redirect: (context, state) {
            final authProvider = context.read<AuthProvider>();
            final isLoggedIn = authProvider.isAuthenticated;
            final isAuthRoute = state.matchedLocation.startsWith('/auth') ||
                state.matchedLocation == '/login' ||
                state.matchedLocation == '/signup';

            if (!isLoggedIn && !isAuthRoute) {
              return '/auth';
            }
            if (isLoggedIn && isAuthRoute) {
              return '/home';
            }
            return null;
          },
          routes: [
            GoRoute(
              path: '/auth',
              builder: (context, state) => const AuthScreen(),
            ),
            GoRoute(
              path: '/login',
              builder: (context, state) => const LoginScreen(),
            ),
            GoRoute(
              path: '/signup',
              builder: (context, state) => const SignupScreen(),
            ),
            ShellRoute(
              builder: (context, state, child) => AppTabs(child: child),
              routes: [
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const MainScreen(),
                ),
                GoRoute(
                  path: '/tasks',
                  builder: (context, state) => const TasksScreen(),
                ),
                GoRoute(
                  path: '/profile',
                  builder: (context, state) => const ProfileScreen(),
                ),
              ],
            ),
          ],
        );
}
