import 'package:flutter/material.dart';

/// Transactions list – Phase 1a.
class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ausgaben')),
      body: const Center(child: Text('Transaktionsliste – Phase 1a')),
    );
  }
}
