import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Dashboard – Phase 1a minimal version.
/// Full implementation in Phase 1a sprint.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schlicht'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
            tooltip: l10n.dashboardMonthTooltip,
          ),
        ],
      ),
      body: Center(
        child: Text(l10n.dashboardPlaceholderTitle),
      ),
    );
  }
}
