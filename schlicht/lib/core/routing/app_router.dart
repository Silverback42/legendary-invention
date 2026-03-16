import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/categories/presentation/categories_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../features/transactions/presentation/add_transaction_screen.dart';
import '../../features/transactions/presentation/edit_transaction_screen.dart';
import '../../features/transactions/presentation/monthly_entry_screen.dart';
import '../../features/budgets/presentation/budgets_screen.dart';
import '../../features/history/presentation/history_screen.dart';
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/onboarding/presentation/life_situation_screen.dart';
import '../../features/onboarding/presentation/customize_template_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../shared/widgets/main_scaffold.dart';
import '../settings/app_settings.dart';

/// Route constants
abstract class AppRoutes {
  static const dashboard = '/';
  static const transactions = '/transactions';
  static const addTransaction = '/transactions/add';
  static const monthlyEntry = '/transactions/monthly';
  static const editTransaction = '/transactions/:id/edit';
  static const budgets = '/budgets';
  static const history = '/history';
  static const settings = '/settings';
  static const categories = '/settings/categories';

  // Onboarding
  static const onboarding = '/onboarding';
  static const onboardingLifeSituation = '/onboarding/life-situation';
  static const onboardingCustomize = '/onboarding/customize';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final settings = ref.watch(appSettingsProvider);

  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    debugLogDiagnostics: false,
    redirect: (context, state) {
      final onboarded = settings.hasCompletedOnboarding;
      final isOnboarding =
          state.matchedLocation.startsWith(AppRoutes.onboarding);

      if (!onboarded && !isOnboarding) return AppRoutes.onboarding;
      if (onboarded && isOnboarding) return AppRoutes.dashboard;
      return null;
    },
    routes: [
      // Onboarding (no shell / no bottom nav)
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const WelcomeScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingLifeSituation,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const LifeSituationScreen(),
          transitionsBuilder: _fadeTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.onboardingCustomize,
        pageBuilder: (context, state) {
          final extra = state.extra;
          return CustomTransitionPage(
            key: state.pageKey,
            child: CustomizeTemplateScreen(
              situationIndex: extra is int ? extra : 4,
            ),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),

      // Main app (with bottom nav shell)
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.transactions,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const TransactionsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.budgets,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const BudgetsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.history,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const HistoryScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const SettingsScreen(),
              transitionsBuilder: _fadeTransition,
            ),
          ),
        ],
      ),

      // Standalone routes (no bottom nav)
      GoRoute(
        path: AppRoutes.addTransaction,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const AddTransactionScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.monthlyEntry,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const MonthlyEntryScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
      GoRoute(
        path: AppRoutes.editTransaction,
        pageBuilder: (context, state) {
          final id = int.tryParse(state.pathParameters['id'] ?? '');
          if (id == null) {
            return CustomTransitionPage(
              key: state.pageKey,
              child: const TransactionsScreen(),
              transitionsBuilder: _fadeTransition,
            );
          }
          return CustomTransitionPage(
            key: state.pageKey,
            child: EditTransactionScreen(transactionId: id),
            transitionsBuilder: _slideUpTransition,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.categories,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const CategoriesScreen(),
          transitionsBuilder: _slideUpTransition,
        ),
      ),
    ],
  );
});

// ---------------------------------------------------------------------------
// Page transition helpers
// ---------------------------------------------------------------------------

Widget _fadeTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  return FadeTransition(opacity: animation, child: child);
}

Widget _slideUpTransition(
  BuildContext context,
  Animation<double> animation,
  Animation<double> secondaryAnimation,
  Widget child,
) {
  final tween = Tween(
    begin: const Offset(0, 0.15),
    end: Offset.zero,
  ).chain(CurveTween(curve: Curves.easeOutCubic));

  return SlideTransition(
    position: animation.drive(tween),
    child: FadeTransition(opacity: animation, child: child),
  );
}
