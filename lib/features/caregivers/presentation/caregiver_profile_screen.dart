import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CaregiverProfileScreen extends StatefulWidget {
  final String caregiverId;
  const CaregiverProfileScreen({super.key, required this.caregiverId});

  @override
  State<CaregiverProfileScreen> createState() => _CaregiverProfileScreenState();
}

class _CaregiverProfileScreenState extends State<CaregiverProfileScreen> {
  final supabase = Supabase.instance.client;
  Map<String, dynamic>? caregiver;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    caregiver = await supabase
        .from('caregivers')
        .select('id, full_name, title, rate_per_hour, city, verified, bio')
        .eq('id', widget.caregiverId)
        .maybeSingle();
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (caregiver == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Caregiver'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: const Center(child: Text('Caregiver not found')),
      );
    }

    final name = caregiver!['full_name'] ?? '';
    final title = caregiver!['title'] ?? '';
    final city = caregiver!['city'] ?? '';
    final rate = caregiver!['rate_per_hour']?.toString() ?? '';
    final verified = caregiver!['verified'] == true;
    final bio = caregiver!['bio'] ?? 'No bio yet';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Caregiver Profile'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 26, child: Icon(Icons.person)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          if (verified)
                            const Padding(
                              padding: EdgeInsets.only(left: 6),
                              child: Icon(Icons.verified, size: 20),
                            ),
                        ],
                      ),
                      Text(title),
                      const SizedBox(height: 4),
                      Text('$city • $rate/hr'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'About',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            Text(bio),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        context.push('/chat/${widget.caregiverId}'),
                    icon: const Icon(Icons.chat_bubble_outline),
                    label: const Text('Message'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => context.push(
                      '/request/new?caregiverId=${widget.caregiverId}',
                    ),
                    icon: const Icon(Icons.assignment_add),
                    label: const Text('Request'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
