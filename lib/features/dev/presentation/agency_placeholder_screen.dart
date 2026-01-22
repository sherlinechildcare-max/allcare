import 'package:flutter/material.dart';

class AgencyPlaceholderScreen extends StatelessWidget {
  const AgencyPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'Agency App (UI Placeholder)\n\nNext: manage caregivers, requests, operations',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
