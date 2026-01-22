import 'package:flutter/material.dart';

class AdminPlaceholderScreen extends StatelessWidget {
  const AdminPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Admin Panel (UI Placeholder)\n\nNext: moderation, approvals, system controls',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
