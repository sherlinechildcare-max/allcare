import 'package:flutter/material.dart';

class CaregiverPlaceholderScreen extends StatelessWidget {
  const CaregiverPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Caregiver App (UI Placeholder)\n\nNext: dashboard, jobs, requests, schedule, profile',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
