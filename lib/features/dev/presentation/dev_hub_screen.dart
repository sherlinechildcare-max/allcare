import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevHubScreen extends StatelessWidget {
  const DevHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dev Hub')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DevTile(
            title: 'Client App',
            subtitle: 'Browse caregivers, requests, messages',
            route: '/client/home',
          ),
          _DevTile(
            title: 'Caregiver App',
            subtitle: 'Caregiver dashboard & requests',
            route: '/dev/caregiver',
          ),
          _DevTile(
            title: 'Agency App',
            subtitle: 'Manage caregivers & operations',
            route: '/dev/agency',
          ),
          _DevTile(
            title: 'Admin Panel',
            subtitle: 'Moderation & system control',
            route: '/dev/admin',
          ),
        ],
      ),
    );
  }
}

class _DevTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String route;

  const _DevTile({
    required this.title,
    required this.subtitle,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward),
        onTap: () => context.go(route),
      ),
    );
  }
}
