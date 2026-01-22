import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RoleSelectScreen extends StatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  State<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends State<RoleSelectScreen> {
  final _email = TextEditingController(text: 'UI mode (auth disabled)');
  String _role = 'Client';

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  void _continueUiMode() {
    // UI-FIRST navigation only (no Supabase auth yet)
    switch (_role) {
      case 'Client':
        context.go('/client/home');
        break;
      case 'Caregiver':
        context.go('/caregiver');
        break;
      case 'Agency':
        context.go('/agency');
        break;
      case 'Admin':
        context.go('/admin');
        break;
      default:
        context.go('/dev');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to AllCare'),
        actions: [
          IconButton(
            tooltip: 'Dev Hub',
            icon: const Icon(Icons.bug_report),
            onPressed: () => context.push('/dev'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _email,
              enabled: false,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(value: 'Client', child: Text('Client')),
                DropdownMenuItem(value: 'Caregiver', child: Text('Caregiver')),
                DropdownMenuItem(value: 'Agency', child: Text('Agency')),
                DropdownMenuItem(value: 'Admin', child: Text('Admin')),
              ],
              onChanged: (v) => setState(() => _role = v ?? 'Client'),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _continueUiMode,
              child: const Text('Continue (UI Mode)'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.push('/dev'),
              child: const Text('Open Dev Hub'),
            ),
          ],
        ),
      ),
    );
  }
}
