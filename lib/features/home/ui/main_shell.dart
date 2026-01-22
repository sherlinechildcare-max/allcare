import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Bottom-nav shell for Client routes.
/// This widget is intentionally "dumb": it only hosts [child] and routes via GoRouter.
class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.child});

  final Widget child;

  static const _tabs = <_ShellTab>[
    _ShellTab(
      label: 'Home',
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      location: '/client/home',
    ),
    _ShellTab(
      label: 'Requests',
      icon: Icons.list_alt_outlined,
      selectedIcon: Icons.list_alt,
      location: '/client/requests',
    ),
    _ShellTab(
      label: 'Messages',
      icon: Icons.chat_bubble_outline,
      selectedIcon: Icons.chat_bubble,
      location: '/client/messages',
    ),
    _ShellTab(
      label: 'Profile',
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      location: '/client/profile',
    ),
  ];

  int _locationToIndex(String location) {
    // Prefer the longest matching prefix.
    for (var i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].location)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (i) {
          if (i == index) return;
          context.go(_tabs[i].location);
        },
        destinations: [
          for (final t in _tabs)
            NavigationDestination(
              icon: Icon(t.icon),
              selectedIcon: Icon(t.selectedIcon),
              label: t.label,
            ),
        ],
      ),
    );
  }
}

class _ShellTab {
  const _ShellTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.location,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final String location;
}
