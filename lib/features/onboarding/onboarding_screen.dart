import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to AllCare'),
        actions: [
          TextButton(
            onPressed: () => context.go('/auth'),
            child: const Text('Skip'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.health_and_safety, size: 72),
            const SizedBox(height: 16),
            const Text(
              'Find trusted care near you',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'Browse caregivers and service pros, send requests, and communicate once accepted.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            const _Bullet(icon: Icons.search, text: 'Search by ZIP, service, or availability'),
            const _Bullet(icon: Icons.send, text: 'Send requests in seconds'),
            const _Bullet(icon: Icons.chat, text: 'Chat & calls after acceptance'),
            const _Bullet(icon: Icons.lock, text: 'Subscriptions unlock contact'),
            const Spacer(),
            FilledButton(
              onPressed: () => context.go('/auth'),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}
