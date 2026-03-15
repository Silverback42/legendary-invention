import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/edit_transaction_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';

/// Route constants
abstract class AppRoutes {
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';
  static const editTransaction = '/transactions/:id/edit';
  static const budgets = '/budgets';
  static const settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    routes: [
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            builder: (context, state) => const TransactionsScreen(),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            builder: (context, state) => const BudgetsScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.addTransaction,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        builder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return const TransactionsScreen();
          }
          return EditTransactionScreen(transactionId: id);
        },
      ),
    ],
  );
});
