import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final emailController = TextEditingController();
  String role = 'client';
  bool loading = false;
  String? error;

  Future<void> _continue() async {
    final email = emailController.text.trim();
    if (email.isEmpty) return;

    setState(() {
      loading = true;
      error = null;
    });

    try {
      await Supabase.instance.client.auth.signInWithOtp(
        email: email,
      );

      if (!mounted) return;

      // 🔑 GO TO VERIFY SCREEN (THIS IS WHAT YOU WERE MISSING)
      context.go('/verify?email=$email&role=$role');
    } catch (e) {
      setState(() => error = e.toString());
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to AllCare')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            RadioListTile(
              title: const Text('Client'),
              value: 'client',
              groupValue: role,
              onChanged: (v) => setState(() => role = v!),
            ),
            RadioListTile(
              title: const Text('Caregiver'),
              value: 'caregiver',
              groupValue: role,
              onChanged: (v) => setState(() => role = v!),
            ),
            RadioListTile(
              title: const Text('Agency'),
              value: 'agency',
              groupValue: role,
              onChanged: (v) => setState(() => role = v!),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            if (error != null)
              Text(error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: loading ? null : _continue,
              child: loading
                  ? const CircularProgressIndicator(strokeWidth: 2)
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}
