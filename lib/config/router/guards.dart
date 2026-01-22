import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RouteGuards {
  static final SupabaseClient _sb = Supabase.instance.client;

  static FutureOr<String?> redirect(
    BuildContext context,
    GoRouterState state,
  ) async {
    final loc = state.matchedLocation;

    // Public routes
    final isAuthRoute = loc.startsWith('/auth');
    final isSplash = loc == '/splash';
    final isOnboarding = loc == '/onboarding';

    final session = _sb.auth.currentSession;

    // Not signed in -> auth
    if (session == null) {
      return isAuthRoute ? null : '/auth';
    }

    // Signed in but on auth -> gate
    if (isAuthRoute) return '/';

    // Load profile (role + onboarding flag)
    final uid = session.user.id;
    final profile = await _sb
        .from('profiles')
        .select('role,onboarding_completed')
        .eq('id', uid)
        .maybeSingle();

    final role = (profile?['role'] as String?) ?? 'client';
    final onboardingCompleted =
        (profile?['onboarding_completed'] as bool?) ?? false;

    // If onboarding not completed -> force splash/onboarding
    if (!onboardingCompleted && !(isSplash || isOnboarding)) {
      return '/splash';
    }

    // If onboarding completed and still on splash/onboarding/gate -> route by role
    if (onboardingCompleted && (isSplash || isOnboarding || loc == '/')) {
      if (role == 'caregiver') return '/caregiver/requests';
      if (role == 'agency') return '/agency/home';
      if (role == 'admin') return '/admin';
      return '/client/home';
    }

    // Role segmentation
    if (role == 'caregiver' && loc.startsWith('/client')) {
      return '/caregiver/requests';
    }
    if (role == 'client' && loc.startsWith('/caregiver')) return '/client/home';

    return null;
  }

  static GoRoute guardedRoute({
    required String path,
    required Widget Function(BuildContext, GoRouterState) builder,
    List<RouteBase> routes = const [],
  }) {
    return GoRoute(
      path: path,
      redirect: RouteGuards.redirect,
      builder: builder,
      routes: routes,
    );
  }
}
