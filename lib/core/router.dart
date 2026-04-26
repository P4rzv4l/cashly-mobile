import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cashly/data/services/auth_provider.dart';
import 'package:cashly/presentation/screens/auth/login_screen.dart';
import 'package:cashly/presentation/screens/auth/register_screen.dart';
import 'package:cashly/presentation/screens/auth/forgot_password_screen.dart';
import 'package:cashly/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:cashly/presentation/screens/transactions/transactions_screen.dart';
import 'package:cashly/presentation/screens/cards/cards_screen.dart';
import 'package:cashly/presentation/screens/goals/goals_screen.dart';
import 'package:cashly/presentation/screens/reserves/reserves_screen.dart';
import 'package:cashly/presentation/screens/assistant/assistant_screen.dart';
import 'package:cashly/presentation/screens/settings/settings_screen.dart';
import 'package:cashly/presentation/widgets/common/app_shell.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/dashboard',
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isAuthRoute = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/cadastro') ||
          state.matchedLocation.startsWith('/esqueci-senha');

      if (!isAuth && !isAuthRoute) return '/login';
      if (isAuth && isAuthRoute) return '/dashboard';
      return null;
    },
    routes: [
      // Public routes
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/cadastro', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/esqueci-senha', builder: (_, __) => const ForgotPasswordScreen()),

      // Protected shell routes
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
          GoRoute(path: '/transacoes', builder: (_, __) => const TransactionsScreen()),
          GoRoute(path: '/cartoes', builder: (_, __) => const CardsScreen()),
          GoRoute(path: '/metas', builder: (_, __) => const GoalsScreen()),
          GoRoute(path: '/reservas', builder: (_, __) => const ReservesScreen()),
          GoRoute(path: '/ia', builder: (_, __) => const AssistantScreen()),
          GoRoute(path: '/configuracoes', builder: (_, __) => const SettingsScreen()),
        ],
      ),
    ],
  );
});
