import 'package:flutter/material.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String route;
  final String description;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.route,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              'Route: $route',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            Text(description, style: Theme.of(context).textTheme.bodyLarge),
            const Spacer(),
            const Center(
              child: Text(
                '🚧 Coming soon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
