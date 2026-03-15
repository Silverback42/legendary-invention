import 'package:flutter/material.dart';

/// Budgets screen – Phase 1b.
class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Budgets')),
      body: const Center(child: Text('Budget-Setup – Phase 1b')),
    );
  }
}
