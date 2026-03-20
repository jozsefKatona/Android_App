import 'package:flutter/material.dart';

class BetweenScreen extends StatelessWidget {
  final VoidCallback onNextScan;

  const BetweenScreen({super.key, required this.onNextScan});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onNextScan,
      child: const Text('Nächsten QR-Code scannen'),
    );
  }
}
