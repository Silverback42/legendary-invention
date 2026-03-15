import 'package:flutter/material.dart';

/// Settings screen – Phase 1a.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Einstellungen')),
      body: const Center(child: Text('Einstellungen – Phase 1a')),
    );
  }
}
