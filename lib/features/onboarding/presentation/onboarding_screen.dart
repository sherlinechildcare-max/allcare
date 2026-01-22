import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  static const _kDoneKey = 'onboarding_done';

  Future<void> _finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDoneKey, true);

    if (context.mounted) {
      context.go('/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(),
              const Text(
                'Care you can trust.\nHelp is close.',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w800,
                  color: AppColors.text,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Find verified caregivers and home services near you, fast.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.muted,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => _finish(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Get Started',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
