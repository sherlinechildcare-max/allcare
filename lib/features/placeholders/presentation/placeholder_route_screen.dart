import "package:flutter/material.dart";
import "placeholders_registry.dart";
import "placeholder_screen.dart";

class PlaceholderRouteScreen extends StatelessWidget {
  final String id;
  const PlaceholderRouteScreen({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final p = kPlaceholders.where((x) => x.id == id).cast<dynamic>().toList();
    if (p.isEmpty) {
      return const PlaceholderScreen(
        title: "Unknown Placeholder",
        subtitle: "This placeholder id does not exist.",
        icon: Icons.help_outline,
        bullets: ["Check the route id in /placeholders"],
      );
    }
    final item = p.first;
    return PlaceholderScreen(
      title: item.title,
      subtitle: item.subtitle,
      icon: item.icon,
      bullets: const [
        "This screen is a UX placeholder (production-ready layout).",
        "Next step: wire real data + state management here.",
        "Dev Menu and /placeholders should always stay navigable.",
      ],
    );
  }
}
