import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverRequestsScreen extends StatelessWidget {
  const CaregiverRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    final user = supabase.auth.currentUser;

    if (user == null) {
      context.go('/auth');
      return const Scaffold();
    }

    final stream = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('caregiver_id', user.id)
        .order('created_at', ascending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Client Requests')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data!;
          if (rows.isEmpty) {
            return const Center(child: Text('No requests yet.'));
          }

          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              return ListTile(
                title: Text(r['notes'] ?? 'New request'),
                subtitle: Text(r['status'] ?? 'pending'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.go('/caregiver/request/${r['id']}');
                },
              );
            },
          );
        },
      ),
    );
  }
}
