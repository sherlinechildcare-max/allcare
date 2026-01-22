import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientHomeScreen extends StatefulWidget {
  final TextEditingController search;

  const ClientHomeScreen({super.key, required this.search});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final supabase = Supabase.instance.client;

  bool loading = true;
  List<Map<String, dynamic>> caregivers = [];

  @override
  void initState() {
    super.initState();
    widget.search.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.search.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => loading = true);

    try {
      final q = widget.search.text.trim();

      final rows = await supabase
          .from('caregivers')
          .select('id, full_name, title, rate_per_hour, city, verified')
          .ilike('full_name', q.isEmpty ? '%' : '%$q%')
          .order('created_at', ascending: false);

      caregivers = List<Map<String, dynamic>>.from(rows);
    } catch (e) {
      // keep UI alive even if table doesn't exist yet
      caregivers = [];
      debugPrint('ClientHomeScreen load error: $e');
    }

    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          TextField(
            controller: widget.search,
            decoration: InputDecoration(
              hintText: 'Search caregivers...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: caregivers.isEmpty
                ? const Center(child: Text('No caregivers yet.'))
                : ListView.separated(
                    itemCount: caregivers.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (_, i) {
                      final c = caregivers[i];
                      return Card(
                        child: ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.person)),
                          title: Row(
                            children: [
                              Expanded(child: Text((c['full_name'] ?? '').toString())),
                              if (c['verified'] == true)
                                const Icon(Icons.verified, size: 18),
                            ],
                          ),
                          subtitle: Text(
                            '${c['title'] ?? ''} • ${c['city'] ?? ''} • ${c['rate_per_hour'] ?? ''}/hr',
                          ),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            final id = c['id'];
                            if (id != null) context.push('/caregiver/$id');
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
