import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevScreen extends StatelessWidget {
  const DevScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('DEV MENU')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _btn(context, 'Splash Screen', '/splash'),
          _btn(context, 'Onboarding', '/onboarding'),
          _btn(context, 'Auth', '/auth'),
          _btn(context, 'Client Home', '/client'),
          _btn(context, 'Caregiver Home', '/caregiver'),
          _btn(context, 'Agency Home', '/agency'),
          _btn(context, 'Agency Apply', '/agency/apply'),
          _btn(context, 'Agency Status', '/agency/status'),
        ],
      ),
    );
  }

  Widget _btn(BuildContext context, String title, String route) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => context.go(route),
        child: Text(title),
      ),
    );
  }
}
