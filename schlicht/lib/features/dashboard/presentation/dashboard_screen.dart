import 'package:flutter/material.dart';

/// Dashboard – Phase 1a minimal version.
/// Full implementation in Phase 1a sprint.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schlicht'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            onPressed: () {},
            tooltip: 'Monat wählen',
          ),
        ],
      ),
      body: const Center(
        child: Text('Dashboard – Phase 1a'),
      ),
    );
  }
}
