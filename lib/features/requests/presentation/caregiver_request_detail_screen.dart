import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverRequestDetailScreen extends StatelessWidget {
  final String requestId;
  const CaregiverRequestDetailScreen({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Request'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: FutureBuilder(
        future: supabase
            .from('requests')
            .select()
            .eq('id', requestId)
            .single(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final r = snapshot.data as Map<String, dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(r['notes'] ?? '', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                Text('Status: ${r['status']}'),
                const Spacer(),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          await supabase
                              .from('requests')
                              .update({'status': 'accepted'})
                              .eq('id', requestId);
                          context.pop();
                        },
                        child: const Text('Accept'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () async {
                          await supabase
                              .from('requests')
                              .update({'status': 'declined'})
                              .eq('id', requestId);
                          context.pop();
                        },
                        child: const Text('Decline'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
