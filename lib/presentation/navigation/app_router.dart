import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:student_app/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:student_app/presentation/screens/cgpa_calculator/cgpa_calculator_screen.dart';
import 'package:student_app/presentation/screens/percentage_calculator/percentage_calculator_screen.dart';
import 'package:student_app/presentation/screens/academic_history/academic_history_screen.dart';
import 'package:student_app/presentation/screens/profile/profile_screen.dart';
import 'package:student_app/presentation/screens/settings/settings_screen.dart';
import 'package:student_app/presentation/screens/ai_assistant/ai_assistant_screen.dart';
import 'package:student_app/presentation/screens/onboarding/onboarding_screen.dart';
import 'package:student_app/presentation/screens/main_shell/main_shell.dart';

class AppRouter {
  static final _rootNavigatorKey = GlobalKey<NavigatorState>();
  static final _shellNavigatorKey = GlobalKey<NavigatorState>();

  static final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      // Onboarding
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // Main Shell with Bottom Navigation
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/cgpa',
            builder: (context, state) => const CGPACalculatorScreen(),
          ),
          GoRoute(
            path: '/percentage',
            builder: (context, state) => const PercentageCalculatorScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const AcademicHistoryScreen(),
          ),
          GoRoute(
            path: '/ai-assistant',
            builder: (context, state) => const AIAssistantScreen(),
          ),
        ],
      ),
      
      // Standalone routes
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
  );
}
