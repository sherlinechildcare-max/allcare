import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AgencyHomeScreen extends StatefulWidget {
  const AgencyHomeScreen({super.key});

  @override
  State<AgencyHomeScreen> createState() => _AgencyHomeScreenState();
}

class _AgencyHomeScreenState extends State<AgencyHomeScreen> {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<String> _status() async {
    final user = _sb.auth.currentUser;
    if (user == null) return 'none';

    final res = await _sb
        .from('agency_applications')
        .select('status')
        .eq('owner_id', user.id)
        .order('created_at', ascending: false)
        .limit(1);

    if (res is List && res.isNotEmpty) return (res.first['status'] ?? 'pending').toString();
    return 'none';
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final s = await _status();
      if (!mounted) return;

      if (s == 'none') {
        context.go('/agency/apply');
      } else {
        context.go('/agency/status');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
