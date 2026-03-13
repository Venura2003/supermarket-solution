import 'package:flutter/material.dart';

class ReceiptsIntegrationScreen extends StatelessWidget {
  const ReceiptsIntegrationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('Receipts & Integrations', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                SizedBox(height: 12),
                Text('Receipt templates, printer and accounting integrations.'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
