import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "placeholders_registry.dart";

class PlaceholdersIndexScreen extends StatelessWidget {
  const PlaceholdersIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bySection = <String, List<dynamic>>{};
    for (final p in kPlaceholders) {
      bySection.putIfAbsent(p.section, () => []).add(p);
    }

    final sections = bySection.keys.toList()..sort();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Placeholder Map"),
      ),
      body: ListView.builder(
        itemCount: sections.length,
        itemBuilder: (context, i) {
          final section = sections[i];
          final items = bySection[section]!;
          return Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(section, style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                ...items.map((p) {
                  return Card(
                    child: ListTile(
                      leading: Icon(p.icon),
                      title: Text(p.title),
                      subtitle: Text("${p.subtitle}\n/p/${p.id}"),
                      isThreeLine: true,
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push("/p/${p.id}"),
                    ),
                  );
                }),
              ],
            ),
          );
        },
      ),
    );
  }
}
