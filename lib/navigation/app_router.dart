import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../ui/screens/home_screen.dart';
import '../ui/screens/tasks_screen.dart';
import '../ui/screens/schedule_screen.dart';
import '../ui/screens/settings_screen.dart';
import '../ui/screens/task_detail_screen.dart';
import '../ui/widgets/main_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage buildPageTransition<T>({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<T>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: animation.drive(
            Tween<Offset>(
              begin: const Offset(0, 0.05),
              end: Offset.zero,
            ).chain(CurveTween(curve: Curves.easeOutCubic)),
          ),
          child: child,
        ),
      );
    },
    transitionDuration: const Duration(milliseconds: 300),
  );
}

final router = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              pageBuilder: (context, state) => buildPageTransition(
                context: context,
                state: state,
                child: const HomeScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/tasks',
              pageBuilder: (context, state) => buildPageTransition(
                context: context,
                state: state,
                child: const TasksScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/schedule',
              pageBuilder: (context, state) => buildPageTransition(
                context: context,
                state: state,
                child: const ScheduleScreen(),
              ),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              pageBuilder: (context, state) => buildPageTransition(
                context: context,
                state: state,
                child: const SettingsScreen(),
              ),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/task-detail/:taskId',
      parentNavigatorKey: _rootNavigatorKey,
      pageBuilder: (context, state) {
        final taskId = state.pathParameters['taskId']!;
        return buildPageTransition(
          context: context,
          state: state,
          child: TaskDetailScreen(taskId: taskId),
        );
      },
    ),
  ],
);
