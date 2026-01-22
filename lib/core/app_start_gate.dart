import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _decide();
    });
  }

  Future<void> _decide() async {
    final supabase = Supabase.instance.client;
    final session = supabase.auth.currentSession;

    if (!mounted) return;

    if (session == null) {
      context.go('/auth');
      return;
    }

    final profile = await supabase
        .from('profiles')
        .select('role, onboarding_completed')
        .eq('id', session.user.id)
        .maybeSingle();

    if (!mounted) return;

    if (profile == null || profile['onboarding_completed'] != true) {
      context.go('/onboarding');
      return;
    }

    switch (profile['role']) {
      case 'client':
        context.go('/client');
        break;
      case 'caregiver':
        context.go('/caregiver');
        break;
      case 'agency':
        context.go('/agency');
        break;
      default:
        context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
