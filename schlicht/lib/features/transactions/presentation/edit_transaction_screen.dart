import 'package:flutter/material.dart';

/// Edit transaction screen – Phase 1a.
class EditTransactionScreen extends StatelessWidget {
  final int transactionId;

  const EditTransactionScreen({super.key, required this.transactionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ausgabe bearbeiten')),
      body: Center(child: Text('Edit #$transactionId – Phase 1a')),
    );
  }
}
