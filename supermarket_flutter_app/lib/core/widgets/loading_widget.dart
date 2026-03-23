import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullPage;

  const LoadingWidget({super.key, this.message, this.fullPage = true});

  @override
  Widget build(BuildContext context) {
    final loader = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(message!, style: Theme.of(context).textTheme.bodyMedium),
        ]
      ],
    );
    return fullPage ? Center(child: loader) : loader;
  }
}
