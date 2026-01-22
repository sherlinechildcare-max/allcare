import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(
          'AllCare',
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
