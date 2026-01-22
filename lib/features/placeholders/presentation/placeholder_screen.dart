import "package:flutter/material.dart";

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<String> bullets;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.bullets = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    subtitle,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (bullets.isNotEmpty)
              ...bullets.map(
                (b) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("•  "),
                      Expanded(child: Text(b)),
                    ],
                  ),
                ),
              ),
            if (bullets.isEmpty)
              Text(
                "This is a production-ready placeholder.\n\nNext we will connect data + real logic here.",
                style: Theme.of(context).textTheme.bodyMedium,
              ),
          ],
        ),
      ),
    );
  }
}
