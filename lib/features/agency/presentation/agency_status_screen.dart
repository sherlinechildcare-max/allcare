import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class AgencyStatusScreen extends StatefulWidget {
  const AgencyStatusScreen({super.key});

  @override
  State<AgencyStatusScreen> createState() => _AgencyStatusScreenState();
}

class _AgencyStatusScreenState extends State<AgencyStatusScreen> {
  SupabaseClient get _sb => Supabase.instance.client;

  Future<Map<String, dynamic>?> _fetchLatest() async {
    final user = _sb.auth.currentUser;
    if (user == null) return null;

    final res = await _sb
        .from('agency_applications')
        .select()
        .eq('owner_id', user.id)
        .order('created_at', ascending: false)
        .limit(1);

    if (res.isNotEmpty) return Map<String, dynamic>.from(res.first);
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Application status'),
        actions: [
          TextButton(
            onPressed: () => context.go('/agency'),
            child: const Text('Home'),
          )
        ],
      ),
      body: FutureBuilder(
        future: _fetchLatest(),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          final app = snap.data;
          if (app == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('No application found.', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 10),
                    const Text('Submit an application to list your agency.', style: TextStyle(color: AppColors.muted)),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.go('/agency/apply'),
                      child: const Text('Apply now'),
                    ),
                  ],
                ),
              ),
            );
          }

          final status = (app['status'] ?? 'pending').toString();

          String title;
          String body;
          IconData icon;
          Color iconColor;

          if (status == 'approved') {
            title = 'Approved ✅';
            body = 'Your agency is approved. You can now manage caregivers and clients.';
            icon = Icons.verified;
            iconColor = AppColors.secondary;
          } else if (status == 'rejected') {
            title = 'Needs review ❗';
            body = 'Your application was not approved. You can submit a new application with updated info.';
            icon = Icons.error_outline;
            iconColor = Colors.redAccent;
          } else {
            title = 'Pending ⏳';
            body = 'We are reviewing your application. You’ll be notified when it’s approved.';
            icon = Icons.hourglass_bottom;
            iconColor = AppColors.primary;
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(icon, color: iconColor),
                    ),
                    const SizedBox(width: 12),
                    Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
                  ],
                ),
                const SizedBox(height: 12),
                Text(body, style: const TextStyle(color: AppColors.muted, height: 1.4)),
                const SizedBox(height: 18),
                const Divider(),

                const SizedBox(height: 12),
                Text('Agency: ${app['agency_name']}', style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('Submitted: ${app['created_at']}', style: const TextStyle(color: AppColors.muted)),

                const Spacer(),
                if (status == 'rejected')
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () => context.go('/agency/apply'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text('Submit new application', style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
