import 'package:flutter/material.dart';
import '../models/chat_thread.dart';
import '../widgets/chat_thread_tile.dart';
import 'chat_thread_screen.dart';

class ClientMessagesScreen extends StatefulWidget {
  const ClientMessagesScreen({super.key});

  @override
  State<ClientMessagesScreen> createState() => _ClientMessagesScreenState();
}

class _ClientMessagesScreenState extends State<ClientMessagesScreen> {
  final _search = TextEditingController();
  bool _showArchived = false;

  final List<ChatThread> _threads = [
    ChatThread(
      id: 't1',
      name: 'Sarah Johnson',
      subtitle: '• Caregiver',
      lastMessage: 'Yes ✅ What time works for you?',
      timeLabel: '2:10 PM',
      unreadCount: 2,
      isOnline: true,
      isPinned: true,
    ),
    ChatThread(
      id: 't2',
      name: 'Michael Green',
      subtitle: '• Caregiver',
      lastMessage: 'I can start tomorrow morning.',
      timeLabel: '12:04 PM',
      unreadCount: 0,
      isOnline: false,
      isPinned: false,
    ),
    ChatThread(
      id: 't3',
      name: 'AllCare Support',
      subtitle: '',
      lastMessage: 'Your request was boosted for visibility.',
      timeLabel: 'Yesterday',
      unreadCount: 1,
      isOnline: true,
      isPinned: false,
    ),
  ];

  final Set<String> _archived = {};

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<ChatThread> get _filtered {
    final q = _search.text.trim().toLowerCase();
    List<ChatThread> list = _threads.where((t) {
      final isArch = _archived.contains(t.id);
      if (_showArchived) {
        if (!isArch) return false;
      } else {
        if (isArch) return false;
      }

      if (q.isEmpty) return true;
      return (t.name.toLowerCase().contains(q) || t.lastMessage.toLowerCase().contains(q));
    }).toList();

    // pinned first (WhatsApp behavior)
    list.sort((a, b) {
      if (a.isPinned == b.isPinned) return 0;
      return a.isPinned ? -1 : 1;
    });

    return list;
  }

  void _open(ChatThread t) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ChatThreadScreen(thread: t)),
    );
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  Future<bool?> _confirm(String title, String body) async {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('OK')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final list = _filtered;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        actions: [
          IconButton(
            tooltip: 'Search',
            icon: const Icon(Icons.search),
            onPressed: () {
              // focus search box
              _snack('Search is below ✅');
            },
          ),
          PopupMenuButton<String>(
            onSelected: (v) {
              if (v == 'Archived') {
                setState(() => _showArchived = true);
              } else if (v == 'All Chats') {
                setState(() => _showArchived = false);
              } else {
                _snack(v);
              }
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: _showArchived ? 'All Chats' : 'Archived', child: Text(_showArchived ? 'All chats' : 'Archived')),
              const PopupMenuItem(value: 'New group', child: Text('New group')),
              const PopupMenuItem(value: 'Broadcast', child: Text('Broadcast')),
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _snack('New chat (UI-only placeholder)'),
        child: const Icon(Icons.chat),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: _showArchived ? 'Search archived…' : 'Search chats…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
          if (!_showArchived)
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Archived'),
              trailing: Text('${_archived.length}', style: theme.textTheme.bodySmall),
              onTap: () => setState(() => _showArchived = true),
            ),
          const Divider(height: 1),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 50),
                          const SizedBox(height: 12),
                          Text(_showArchived ? 'No archived chats' : 'No messages yet',
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            _showArchived
                                ? 'Archived chats will appear here.'
                                : 'Messages will appear after a caregiver accepts a request.',
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) {
                      final t = list[i];

                      return Dismissible(
                        key: ValueKey(t.id),
                        confirmDismiss: (dir) async {
                          if (dir == DismissDirection.startToEnd) {
                            // swipe right -> archive/unarchive
                            final will = await _confirm(
                              _archived.contains(t.id) ? 'Unarchive chat?' : 'Archive chat?',
                              'This is UI-only for now.',
                            );
                            if (will == true) {
                              setState(() {
                                if (_archived.contains(t.id)) {
                                  _archived.remove(t.id);
                                } else {
                                  _archived.add(t.id);
                                }
                              });
                            }
                            return false;
                          } else {
                            // swipe left -> delete (UI-only)
                            final will = await _confirm('Delete chat?', 'This is UI-only for now.');
                            if (will == true) {
                              setState(() {
                                _threads.removeWhere((x) => x.id == t.id);
                                _archived.remove(t.id);
                              });
                            }
                            return false;
                          }
                        },
                        background: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.centerLeft,
                          child: const Row(
                            children: [
                              Icon(Icons.archive_outlined),
                              SizedBox(width: 8),
                              Text('Archive'),
                            ],
                          ),
                        ),
                        secondaryBackground: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          alignment: Alignment.centerRight,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Delete'),
                              SizedBox(width: 8),
                              Icon(Icons.delete_outline),
                            ],
                          ),
                        ),
                        child: ChatThreadTile(
                          thread: t,
                          onTap: () => _open(t),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
