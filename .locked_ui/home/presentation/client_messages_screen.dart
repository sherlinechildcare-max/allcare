import 'package:flutter/material.dart';
import '../../chat/presentation/chat_thread_screen.dart';

class ClientMessagesScreen extends StatefulWidget {
  const ClientMessagesScreen({super.key});

  @override
  State<ClientMessagesScreen> createState() => _ClientMessagesScreenState();
}

class _ClientMessagesScreenState extends State<ClientMessagesScreen> {
  final TextEditingController _search = TextEditingController();

  final List<_Thread> _threads = [
    _Thread(
      id: 't1',
      name: 'Sarah M. (Caregiver)',
      phone: '+1 (809) 505-5515',
      lastMessage: 'Perfect — I can arrive 10 minutes early.',
      timeLabel: '6m',
      unread: 2,
      isOnline: true,
      lastSeenLabel: 'online',
    ),
    _Thread(
      id: 't2',
      name: 'Agency Support',
      phone: '+1 (555) 010-0000',
      lastMessage: 'Your request was boosted successfully.',
      timeLabel: '58m',
      unread: 0,
      isOnline: false,
      lastSeenLabel: 'last seen 58m ago',
    ),
    _Thread(
      id: 't3',
      name: 'John K. (Caregiver)',
      phone: '+1 (555) 222-1111',
      lastMessage: 'Thanks! What’s the parking situation?',
      timeLabel: '3h',
      unread: 0,
      isOnline: false,
      lastSeenLabel: 'last seen 3h ago',
    ),
  ];

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final list = q.isEmpty
        ? _threads
        : _threads.where((t) => t.name.toLowerCase().contains(q)).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search messages…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                isDense: true,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: list.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final t = list[i];
                return ListTile(
                  leading: Stack(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        child: Text(_initials(t.name)),
                      ),
                      if (t.isOnline)
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.green,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  title: Text(
                    t.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    t.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(t.timeLabel, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 6),
                      if (t.unread > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${t.unread}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ChatThreadScreen(
                          threadId: t.id,
                          initialName: t.name,
                          phone: t.phone,
                          avatarUrl: null,
                          isOnline: t.isOnline,
                          lastSeenLabel: t.lastSeenLabel,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.split(' ').where((p) => p.trim().isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final a = parts.first[0].toUpperCase();
    final b = parts.length > 1 ? parts[1][0].toUpperCase() : '';
    return '$a$b';
  }
}

class _Thread {
  final String id;
  final String name;
  final String phone;
  final String lastMessage;
  final String timeLabel;
  final int unread;
  final bool isOnline;
  final String lastSeenLabel;

  _Thread({
    required this.id,
    required this.name,
    required this.phone,
    required this.lastMessage,
    required this.timeLabel,
    required this.unread,
    required this.isOnline,
    required this.lastSeenLabel,
  });
}
