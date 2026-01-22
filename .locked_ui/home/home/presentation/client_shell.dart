import 'package:flutter/material.dart';
import 'package:allcare/features/dev/presentation/dev_menu_screen.dart';
import 'package:go_router/go_router.dart';

class ClientShell extends StatelessWidget {
  final Widget child;
  const ClientShell({super.key, required this.child});

  static const tabs = <_TabItem>[
    _TabItem(label: 'Home', icon: Icons.home_outlined, route: '/client/home'),
    _TabItem(label: 'Requests', icon: Icons.assignment_outlined, route: '/client/requests'),
    _TabItem(label: 'Messages', icon: Icons.chat_bubble_outline, route: '/client/messages'),
    _TabItem(label: 'Profile', icon: Icons.person_outline, route: '/client/profile'),
  ];

  int _locationToIndex(String location) {
    final idx = tabs.indexWhere((t) => location.startsWith(t.route));
    return idx < 0 ? 0 : idx;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final currentIndex = _locationToIndex(location);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AllCare'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const DevMenuScreen()),
              );
            },
          ),
        ],
      ),

      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) => context.go(tabs[i].route),
        destinations: [
          for (final t in tabs) NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}

class _TabItem {
  final String label;
  final IconData icon;
  final String route;
  const _TabItem({required this.label, required this.icon, required this.route});
}
