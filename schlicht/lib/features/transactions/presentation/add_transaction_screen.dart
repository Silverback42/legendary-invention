import 'package:flutter/material.dart';

/// Quick-Entry screen – Phase 1a.
class AddTransactionScreen extends StatelessWidget {
  const AddTransactionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ausgabe erfassen')),
      body: const Center(child: Text('Quick-Entry – Phase 1a')),
    );
  }
}
