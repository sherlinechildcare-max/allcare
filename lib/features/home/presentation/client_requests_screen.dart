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
  bool loading = true;
  List<Map<String, dynamic>> rows = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    final uid = supabase.auth.currentUser?.id;
    if (uid == null) {
      if (mounted) context.go('/auth');
      return;
    }

    final data = await supabase
        .from('requests')
        .select('id, caregiver_id, status, notes, created_at')
        .eq('client_user_id', uid)
        .order('created_at', ascending: false);

    rows = List<Map<String, dynamic>>.from(data);
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requests'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          )
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : rows.isEmpty
              ? const Center(child: Text('No requests yet.'))
              : ListView.separated(
                  itemCount: rows.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final r = rows[i];
                    final status = (r['status'] ?? 'pending').toString();
                    final caregiverId = (r['caregiver_id'] ?? '').toString();
                    final createdAt = (r['created_at'] ?? '').toString();

                    return ListTile(
                      title: Text('Request • $status'),
                      subtitle: Text('Caregiver: $caregiverId\n$createdAt'),
                      isThreeLine: true,
                    );
                  },
                ),
    );
  }
}
