import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VerifyCodeScreen extends StatefulWidget {
  const VerifyCodeScreen({
    super.key,
    required this.email,
    required this.role,
  });

  final String email;
  final String role;

  @override
  State<VerifyCodeScreen> createState() => _VerifyCodeScreenState();
}

class _VerifyCodeScreenState extends State<VerifyCodeScreen> {
  final _code = TextEditingController();
  bool loading = false;
  String? error;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final token = _code.text.trim();
      if (token.length < 6) {
        throw Exception('Enter the 6-digit code from Mailpit.');
      }

      await Supabase.instance.client.auth.verifyOTP(
        email: widget.email,
        token: token,
        type: OtpType.magiclink,
      );

      if (!mounted) return;

      // After login, send user to correct home by role
      // Adjust these routes if your app uses different paths.
      switch (widget.role) {
        case 'caregiver':
          Navigator.of(context).popUntil((r) => r.isFirst);
          context.go('/caregiver');
          break;
        case 'agency':
          Navigator.of(context).popUntil((r) => r.isFirst);
          context.go('/agency');
          break;
        default:
          Navigator.of(context).popUntil((r) => r.isFirst);
          context.go('/client');
      }
    } on AuthException catch (e) {
      setState(() => error = e.message);
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify code')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Email: ${widget.email}'),
            const SizedBox(height: 12),
            TextField(
              controller: _code,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '6-digit code',
                hintText: 'e.g. 822999',
              ),
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : _verify,
              child: loading
                  ? const SizedBox(
                      height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Verify & Sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
