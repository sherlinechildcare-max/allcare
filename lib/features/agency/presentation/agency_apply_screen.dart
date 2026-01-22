import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_colors.dart';

class AgencyApplyScreen extends StatefulWidget {
  const AgencyApplyScreen({super.key});

  @override
  State<AgencyApplyScreen> createState() => _AgencyApplyScreenState();
}

class _AgencyApplyScreenState extends State<AgencyApplyScreen> {
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _website = TextEditingController();
  final _license = TextEditingController();
  final _address = TextEditingController();

  bool _loading = false;
  String? _error;

  SupabaseClient get _sb => Supabase.instance.client;

  Future<void> _submit() async {
    final user = _sb.auth.currentUser;
    if (user == null) return;

    if (_name.text.trim().isEmpty) {
      setState(() => _error = 'Agency name is required.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await _sb.from('agency_applications').insert({
        'owner_id': user.id,
        'agency_name': _name.text.trim(),
        'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
        'email': _email.text.trim().isEmpty ? null : _email.text.trim(),
        'website': _website.text.trim().isEmpty ? null : _website.text.trim(),
        'license_number': _license.text.trim().isEmpty ? null : _license.text.trim(),
        'address': _address.text.trim().isEmpty ? null : _address.text.trim(),
        'status': 'pending',
      });

      if (!mounted) return;
      context.go('/agency/status');
    } catch (e) {
      setState(() => _error = 'Submit failed: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    _email.dispose();
    _website.dispose();
    _license.dispose();
    _address.dispose();
    super.dispose();
  }

  InputDecoration _dec(String label, String hint) => InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Agency Application')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const Text(
              'Apply to list your agency on AllCare',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppColors.text),
            ),
            const SizedBox(height: 8),
            const Text(
              'We verify agencies to protect clients and caregivers. Most reviews finish within 24–72 hours.',
              style: TextStyle(color: AppColors.muted, height: 1.4),
            ),
            const SizedBox(height: 18),

            TextField(controller: _name, decoration: _dec('Agency name', 'AllCare Home Services LLC')),
            const SizedBox(height: 12),
            TextField(controller: _phone, decoration: _dec('Phone (optional)', '(555) 555-5555')),
            const SizedBox(height: 12),
            TextField(controller: _email, decoration: _dec('Business email (optional)', 'agency@example.com')),
            const SizedBox(height: 12),
            TextField(controller: _website, decoration: _dec('Website (optional)', 'https://youragency.com')),
            const SizedBox(height: 12),
            TextField(controller: _license, decoration: _dec('License number (optional)', 'State license / NPI / etc')),
            const SizedBox(height: 12),
            TextField(
              controller: _address,
              decoration: _dec('Address (optional)', 'Street, City, State, ZIP'),
              maxLines: 2,
            ),
            const SizedBox(height: 14),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _loading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Submit application', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
