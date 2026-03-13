import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String userRole;
  final Function(String) onNavigate;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.userRole,
    required this.onNavigate,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    // Use new Sidebar from layout/sidebar.dart
    // ...existing code replaced by new Sidebar...
    return const SizedBox.shrink();
  }
}
