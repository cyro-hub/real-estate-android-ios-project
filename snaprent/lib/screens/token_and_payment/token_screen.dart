import 'package:flutter/material.dart';

class TokenScreen extends StatelessWidget {
  final String tokenPackageId;

  const TokenScreen({super.key, required this.tokenPackageId});

  void _renewToken(BuildContext context) {
    // TODO: Implement your actual renewal API call here
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("Renewing token: $tokenPackageId")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Renew Token")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Text(
              "Token Package ID:",
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              tokenPackageId,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () => _renewToken(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 14,
                ),
              ),
              child: const Text("Renew Token", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
