import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class DevMenuScreen extends StatelessWidget {
  const DevMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // NOTE: These routes must exist in app_router.dart.
    // If a route is missing, tapping it will throw — then we add that route next.
    final items = <_DevItem>[
      _DevItem.header("App Start"),
      _DevItem.route("Splash", "/splash", icon: Icons.health_and_safety),
      _DevItem.route("Onboarding", "/onboarding", icon: Icons.flag),
      _DevItem.route("Auth / Role Select", "/auth", icon: Icons.verified_user),
      _DevItem.route("Dev Hub", "/dev", icon: Icons.developer_mode),

      _DevItem.header("Client App"),
      _DevItem.route("Client Home", "/client/home", icon: Icons.home),
      _DevItem.route("Client Requests", "/client/requests", icon: Icons.receipt_long),
      _DevItem.route("Client Messages", "/client/messages", icon: Icons.chat_bubble_outline),
      _DevItem.route("Client Profile", "/client/profile", icon: Icons.person_outline),

      _DevItem.header("Caregiver App"),
      _DevItem.route("Caregiver Placeholder", "/caregiver", icon: Icons.volunteer_activism),

      _DevItem.header("Agency App"),
      _DevItem.route("Agency Placeholder", "/agency", icon: Icons.apartment),

      _DevItem.header("Admin"),
      _DevItem.route("Admin Placeholder", "/admin", icon: Icons.admin_panel_settings),

      _DevItem.header("Data Tools (UI only for now)"),
      _DevItem.action("Seed Caregivers", icon: Icons.upload, onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seed Caregivers: wire to Supabase later")),
        );
      }),
      _DevItem.action("Seed Request", icon: Icons.playlist_add, onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Seed Request: wire to Supabase later")),
        );
      }),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dev Menu"),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final item = items[index];

          if (item.isHeader) {
            return Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(
                item.title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            );
          }

          return Card(
            child: ListTile(
              leading: Icon(item.icon),
              title: Text(item.title),
              subtitle: item.routePath != null ? Text(item.routePath!) : null,
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                if (item.onTap != null) {
                  item.onTap!();
                  return;
                }
                final route = item.routePath;
                if (route == null) return;
                context.push(route);
              },
            ),
          );
        },
      ),
    );
  }
}

class _DevItem {
  final String title;
  final String? routePath;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isHeader;

  const _DevItem._(
    this.title, {
    required this.icon,
    this.routePath,
    this.onTap,
    this.isHeader = false,
  });

  static _DevItem header(String title) =>
      _DevItem._(title, icon: Icons.more_horiz, isHeader: true);

  static _DevItem route(String title, String routePath, {IconData icon = Icons.link}) =>
      _DevItem._(title, routePath: routePath, icon: icon);

  static _DevItem action(String title, {IconData icon = Icons.play_arrow, required VoidCallback onTap}) =>
      _DevItem._(title, icon: icon, onTap: onTap);
}
