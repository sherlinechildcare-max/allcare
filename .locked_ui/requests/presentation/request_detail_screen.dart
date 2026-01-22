import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestDetailScreen extends StatelessWidget {
  final String requestId;
  const RequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    final stream = supabase
        .from('requests')
        .stream(primaryKey: ['id'])
        .eq('id', requestId)
        .limit(1);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: StreamBuilder(
        stream: stream,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final rows = snapshot.data as List;
          if (rows.isEmpty) {
            return const Center(child: Text('Request not found'));
          }

          final r = rows.first;
          final status = r['status'] ?? 'pending';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _row('Status', status),
                _row('Requested Date', r['requested_date'] ?? '—'),
                _row('Created', r['created_at']?.toString().substring(0, 16) ?? ''),
                const SizedBox(height: 16),
                const Text(
                  'Notes',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(r['notes'] ?? 'No notes provided'),
                const Spacer(),
                if (status == 'accepted')
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Open Chat'),
                      onPressed: () => context.push('/chat/${r['caregiver_id']}'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 120, child: Text(label)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
