
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientRequestsScreen extends StatefulWidget {
  const ClientRequestsScreen({super.key});

  @override
  State<ClientRequestsScreen> createState() => _ClientRequestsScreenState();
}

class _ClientRequestsScreenState extends State<ClientRequestsScreen> {
  final supabase = Supabase.instance.client;
  final Set<String> _openedChats = {};

  @override
  Widget build(BuildContext context) {
    final user = supabase.auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }

    final stream = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('client_user_id', user.id)
        .order('created_at', ascending: false);

    return Scaffold(
      appBar: AppBar(title: const Text('My Requests')),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data as List;

          // 🔥 AUTO OPEN CHAT WHEN ACCEPTED
          for (final r in rows) {
            final id = r['id'].toString();
            final status = r['status'];
            final caregiverId = r['caregiver_id'];

            if (status == 'accepted' && !_openedChats.contains(id)) {
              _openedChats.add(id);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  context.push('/chat/$caregiverId');
                }
              });
            }
          }

          if (rows.isEmpty) {
            return const Center(child: Text('No requests yet.'));
          }

          return ListView.builder(
            itemCount: rows.length,
            itemBuilder: (context, i) {
              final r = rows[i];
              final status = (r['status'] ?? 'pending').toString();

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text(r['notes'] ?? 'Care request'),
                  subtitle: Text('Status: $status'),
                  trailing: _statusIcon(status),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _statusIcon(String status) {
    switch (status) {
      case 'accepted':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'declined':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.hourglass_top, color: Colors.orange);
    }
  }
}
