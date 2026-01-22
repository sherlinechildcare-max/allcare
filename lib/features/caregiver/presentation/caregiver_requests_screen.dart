
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverRequestsScreen extends StatefulWidget {
  const CaregiverRequestsScreen({super.key});

  @override
  State<CaregiverRequestsScreen> createState() => _CaregiverRequestsScreenState();
}

class _CaregiverRequestsScreenState extends State<CaregiverRequestsScreen> {
  final supabase = Supabase.instance.client;

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not authenticated')),
      );
    }

    final stream = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('caregiver_id', user.id)
        .order('created_at', ascending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Incoming Requests')),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data as List;

          if (rows.isEmpty) {
            return const Center(child: Text('No requests yet.'));
          }

          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final status = r['status'] ?? 'pending';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(r['notes'] ?? 'New care request'),
                  subtitle: Text('Status: $status'),
                  trailing: status == 'pending'
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _updateStatus(r['id'], 'accepted'),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _updateStatus(r['id'], 'declined'),
                            ),
                          ],
                        )
                      : Text(status.toString().toUpperCase()),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateStatus(String id, String status) async {
    await supabase
        .from('requests')
        .update({'status': status})
        .eq('id', id);
  }
}
