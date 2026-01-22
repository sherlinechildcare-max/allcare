import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RequestCreateScreen extends StatefulWidget {
  final String caregiverId;
  const RequestCreateScreen({super.key, required this.caregiverId});

  @override
  State<RequestCreateScreen> createState() => _RequestCreateScreenState();
}

class _RequestCreateScreenState extends State<RequestCreateScreen> {
  final supabase = Supabase.instance.client;
  final _notes = TextEditingController();
  DateTime? _date;
  bool _busy = false;

  @override
  void dispose() {
    _notes.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      context.go('/auth');
      return;
    }

    setState(() => _busy = true);

    try {
      await supabase.from('requests').insert({
        'client_user_id': user.id,
        'caregiver_id': widget.caregiverId,
        'requested_date': _date?.toIso8601String().substring(0, 10),
        'notes': _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      });

      if (mounted) {
        context.go('/client'); // back to home
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Request'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Requested date'),
              subtitle: Text(
                _date == null
                    ? 'Not selected'
                    : _date!.toLocal().toString().substring(0, 10),
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: _busy
                  ? null
                  : () async {
                      final now = DateTime.now();
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: now,
                        lastDate: DateTime(now.year + 1),
                        initialDate: now,
                      );
                      if (picked != null) {
                        setState(() => _date = picked);
                      }
                    },
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _notes,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const CircularProgressIndicator()
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
