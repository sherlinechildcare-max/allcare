import 'package:flutter/material.dart';

import '../../services/ui/services_home_screen.dart';

class ClientShellScreen extends StatefulWidget {
  const ClientShellScreen({super.key});

  @override
  State<ClientShellScreen> createState() => _ClientShellScreenState();
}

class _ClientShellScreenState extends State<ClientShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const ServicesHomeScreen(), // Home tab
      const _Placeholder(title: 'Booking'),
      const _Placeholder(title: 'Chat'),
      const _Placeholder(title: 'Saved'),
      const _Placeholder(title: 'Profile'),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.event_note), label: 'Booking'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_bubble_outline), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.bookmark_border), label: 'Saved'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title (placeholder)')),
    );
  }
}
