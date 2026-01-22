import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientProfileTabScreen extends StatefulWidget {
  const ClientProfileTabScreen({super.key});

  @override
  State<ClientProfileTabScreen> createState() => _ClientProfileTabScreenState();
}

class _ClientProfileTabScreenState extends State<ClientProfileTabScreen> {
  final supabase = Supabase.instance.client;

  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _city = TextEditingController();
  final _bio = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _city.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final userId = supabase.auth.currentUser!.id;

      final row = await supabase
          .from('profiles')
          .select('full_name, phone, city, bio')
          .eq('id', userId)
          .maybeSingle();

      if (row != null) {
        _name.text = (row['full_name'] ?? '') as String;
        _phone.text = (row['phone'] ?? '') as String;
        _city.text = (row['city'] ?? '') as String;
        _bio.text = (row['bio'] ?? '') as String;
      }
    } catch (e) {
      _error = 'Failed to load profile: $e';
    }

    if (mounted) setState(() => _loading = false);
  }

  Future<void> _save() async {
    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final userId = supabase.auth.currentUser!.id;
      await supabase.from('profiles').upsert({
        'id': userId,
        'full_name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'city': _city.text.trim(),
        'bio': _bio.text.trim(),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
    } catch (e) {
      _error = 'Failed to save profile: $e';
    }

    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    final email = supabase.auth.currentUser?.email ?? '';

    if (_loading) return const Center(child: CircularProgressIndicator());

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Signed in as:\n$email'),
        const SizedBox(height: 16),

        if (_error != null) ...[
          Text(_error!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 12),
        ],

        TextField(controller: _name, decoration: const InputDecoration(labelText: 'Full name')),
        const SizedBox(height: 10),
        TextField(controller: _phone, decoration: const InputDecoration(labelText: 'Phone')),
        const SizedBox(height: 10),
        TextField(controller: _city, decoration: const InputDecoration(labelText: 'City')),
        const SizedBox(height: 10),
        TextField(
          controller: _bio,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Bio (optional)'),
        ),
        const SizedBox(height: 16),

        ElevatedButton(
          onPressed: _saving ? null : _save,
          child: _saving
              ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
              : const Text('Save'),
        ),
        const SizedBox(height: 10),

        OutlinedButton(
          onPressed: () async {
            await supabase.auth.signOut();
          },
          child: const Text('Sign out'),
        ),
      ],
    );
  }
}
