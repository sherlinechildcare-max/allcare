import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AppStartGate extends StatefulWidget {
  const AppStartGate({super.key});

  @override
  State<AppStartGate> createState() => _AppStartGateState();
}

class _AppStartGateState extends State<AppStartGate> {
  final supabase = Supabase.instance.client;
  String? _error;

  @override
  void initState() {
    super.initState();
    _decideNext();
  }

  Future<void> _decideNext() async {
    try {
      // Hard safety timeout so we never hang forever.
      await _decideNextInternal().timeout(const Duration(seconds: 8));
    } on TimeoutException {
      _setError('Startup timed out. Please try again.');
    } catch (e) {
      _setError('Startup error: $e');
    }
  }

  Future<void> _decideNextInternal() async {
    final user = supabase.auth.currentUser;

    debugPrint('[AppStartGate] user=${user?.id}');

    if (user == null) {
      _go('/auth');
      return;
    }

    Map<String, dynamic>? profile;
    try {
      profile = await supabase
          .from('profiles')
          .select('id, role, onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();
    } catch (e) {
      _setError('Profile fetch failed: $e');
      return;
    }

    debugPrint('[AppStartGate] profile=$profile');

    if (profile == null || profile['role'] == null) {
      _go('/role-select'); // make sure this route exists in your router
      return;
    }

    if (profile['onboarding_completed'] != true) {
      _go('/onboarding');
      return;
    }

    final role = (profile['role'] as String).toLowerCase();

    // Agency approval gate (optional)
    if (role == 'agency') {
      Map<String, dynamic>? application;
      try {
        application = await supabase
            .from('agency_applications')
            .select('status')
            .eq('owner_id', user.id)
            .maybeSingle();
      } catch (e) {
        _setError('Agency status check failed: $e');
        return;
      }

      debugPrint('[AppStartGate] agency_application=$application');

      if (application == null || application['status'] != 'approved') {
        _go('/agency-status'); // make sure this route exists
        return;
      }
    }

    // ✅ MUST MATCH YOUR go_router PATHS
    if (role == 'caregiver') {
      _go('/caregiver/requests');
      return;
    }
    if (role == 'agency') {
      _go('/agency/home');
      return;
    }
    if (role == 'admin') {
      _go('/admin');
      return;
    }
    _go('/client/home');
  }

  void _go(String route) {
    if (!mounted) return;
    debugPrint('[AppStartGate] go => $route');
    context.go(route);
  }

  void _setError(String msg) {
    debugPrint('[AppStartGate] ERROR: $msg');
    if (!mounted) return;
    setState(() => _error = msg);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _error == null
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Text(_error!, textAlign: TextAlign.center),
              ),
      ),
    );
  }
}
