import 'package:flutter/material.dart';
import '../../l10n/generated/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/routing/app_router.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final location = GoRouterState.of(context).matchedLocation;
    final currentIndex = _indexForLocation(location);

    return Scaffold(
      body: child,
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addTransaction),
        tooltip: l10n.addTransaction,
        child: const Icon(Icons.add, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) => _onNavTap(context, index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.grid_view_outlined),
            selectedIcon: const Icon(Icons.grid_view),
            label: l10n.navDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.receipt_long_outlined),
            selectedIcon: const Icon(Icons.receipt_long),
            label: l10n.navTransactions,
          ),
          NavigationDestination(
            icon: const Icon(Icons.donut_large_outlined),
            selectedIcon: const Icon(Icons.donut_large),
            label: l10n.navBudgets,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.navSettings,
          ),
        ],
      ),
    );
  }

  int _indexForLocation(String location) {
    if (location.startsWith(AppRoutes.transactions)) return 1;
    if (location.startsWith(AppRoutes.budgets)) return 2;
    if (location.startsWith(AppRoutes.settings)) return 3;
    return 0; // dashboard
  }

  void _onNavTap(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppRoutes.dashboard);
        return;
      case 1:
        context.go(AppRoutes.transactions);
        return;
      case 2:
        context.go(AppRoutes.budgets);
        return;
      case 3:
        context.go(AppRoutes.settings);
        return;
    }
  }
}
