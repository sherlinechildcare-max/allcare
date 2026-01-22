import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/ui/services_home_screen.dart';

class VerifyCodeScreen extends StatefulWidget {
  final String email;
  final String role;

  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.role,
  });

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = codeController.text.trim();

    debugPrint('VERIFY pressed. email=${widget.email} role=${widget.role} code=$code');

    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit code from Mailpit')),
      );
      return;
    }

    setState(() => isLoading = true);
    try {
      final res = await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: code,
        type: OtpType.email,
      );

      debugPrint('verifyOTP result user=${res.user?.id}');

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const ServicesHomeScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint('ERROR verifyOTP: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verify failed: $e')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _resend() async {
    debugPrint('RESEND pressed. email=${widget.email}');
    try {
      await Supabase.instance.client.auth.signInWithOtp(email: widget.email);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Code resent. Check Mailpit.')),
      );
    } catch (e) {
      debugPrint('ERROR resend: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Resend failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final canVerify = !isLoading && codeController.text.trim().isNotedEmpty;

    return Scaffold(
      appBar: AppBar(title: const Text('Enter Code')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('We sent a code to: ${widget.email}'),
            const SizedBox(height: 16),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '6-digit code',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : _verify,
                child: isLoading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Verify & Continue'),
              ),
            ),
            TextButton(
              onPressed: isLoading ? null : _resend,
              child: const Text('Resend code'),
            ),
          ],
        ),
      ),
    );
  }
}

extension on String {
  bool get isNotedEmpty => trim().isNotEmpty;
}
