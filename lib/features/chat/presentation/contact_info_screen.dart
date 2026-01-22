import 'package:flutter/material.dart';

class ContactInfoScreen extends StatelessWidget {
  final String name;
  final String phone;
  final bool isOnline;
  final String lastSeenLabel;

  final ValueChanged<String> onEditName;
  final VoidCallback onAudioCall;
  final VoidCallback onVideoCall;

  const ContactInfoScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.isOnline,
    required this.lastSeenLabel,
    required this.onEditName,
    required this.onAudioCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    final subtitle = isOnline ? 'online' : lastSeenLabel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact info'),
        actions: [
          TextButton(
            onPressed: () => _editName(context),
            child: const Text('Edit'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
        children: [
          Center(
            child: Column(
              children: [
                CircleAvatar(radius: 44, child: Text(_initials(name), style: const TextStyle(fontSize: 22))),
                const SizedBox(height: 12),
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text(phone, style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 6),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: _ActionTile(
                  icon: Icons.call_outlined,
                  label: 'Audio',
                  onTap: onAudioCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.videocam_outlined,
                  label: 'Video',
                  onTap: onVideoCall,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ActionTile(
                  icon: Icons.search,
                  label: 'Search',
                  onTap: () => _toast(context, 'Search inside chat coming from message index later.'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _SectionCard(
            title: 'Media, links, and docs',
            trailing: '0',
            onTap: () => _toast(context, 'We will connect this to Supabase Storage.'),
            icon: Icons.photo_library_outlined,
          ),
          _SectionCard(
            title: 'Notifications',
            trailing: '',
            onTap: () => _toast(context, 'Notification settings can be per-thread in Supabase later.'),
            icon: Icons.notifications_none,
          ),

          const SizedBox(height: 12),
          const Text('Privacy', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),

          _SwitchRow(
            icon: Icons.lock_outline,
            title: 'Lock chat',
            subtitle: 'Lock and hide this chat on this device.',
            value: false,
            onChanged: (_) => _toast(context, 'Lock chat can be enabled later.'),
          ),
          _SectionCard(
            title: 'Disappearing messages',
            trailing: 'Off',
            onTap: () => _toast(context, 'We can implement TTL in Supabase later.'),
            icon: Icons.timer_outlined,
          ),
          _SectionCard(
            title: 'Advanced chat privacy',
            trailing: 'Off',
            onTap: () => _toast(context, 'Later: screenshot prevention, forwarding limits, etc.'),
            icon: Icons.shield_outlined,
          ),

          const SizedBox(height: 18),

          _DangerCard(
            icon: Icons.block,
            title: 'Block $name',
            onTap: () => _toast(context, 'Block will be enforced when Supabase auth + rules are enabled.'),
          ),
          const SizedBox(height: 8),
          _DangerCard(
            icon: Icons.report_outlined,
            title: 'Report $name',
            onTap: () => _toast(context, 'Report will create a moderation record later.'),
          ),
        ],
      ),
    );
  }

  Future<void> _editName(BuildContext context) async {
    final c = TextEditingController(text: name);
    final res = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Edit name'),
        content: TextField(
          controller: c,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (res != null && res.isNotEmpty) onEditName(res);
  }

  void _toast(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts.first[0].toUpperCase();
    final b = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    return '$a$b';
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.7),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(
            children: [
              Icon(icon),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String trailing;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing.isEmpty ? const Icon(Icons.chevron_right) : Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(trailing),
            const SizedBox(width: 6),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}

class _DangerCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DangerCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.error;
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w700)),
        onTap: onTap,
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: Switch(value: value, onChanged: onChanged),
      ),
    );
  }
}
