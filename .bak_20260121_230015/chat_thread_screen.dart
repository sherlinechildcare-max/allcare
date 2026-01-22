import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ChatThreadScreen extends StatefulWidget {
  final String caregiverId;
  const ChatThreadScreen({super.key, required this.caregiverId});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final supabase = Supabase.instance.client;
  final _ctrl = TextEditingController();

  String? _threadId;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _ensureThread();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _ensureThread() async {
    final user = supabase.auth.currentUser;
    if (user == null) {
      if (mounted) context.go('/auth');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final row = await supabase
          .from('chat_threads')
          .upsert(
            {
              'client_user_id': user.id,
              'caregiver_id': widget.caregiverId,
              'last_message_at': DateTime.now().toIso8601String(),
            },
            onConflict: 'client_user_id,caregiver_id',
          )
          .select('id')
          .single();

      _threadId = row['id'].toString();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _send() async {
    final user = supabase.auth.currentUser;
    final body = _ctrl.text.trim();
    if (user == null || body.isEmpty || _threadId == null) return;

    final threadId = _threadId!;

    _ctrl.clear();

    try {
      await supabase.from('chat_messages').insert({
        'thread_id': threadId,
        'sender_user_id': user.id,
        'body': body,
      });

      await supabase.from('chat_threads').update({
        'last_message_at': DateTime.now().toIso8601String(),
      }).eq('id', threadId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Send failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Chat'),
          leading: BackButton(onPressed: () => context.pop()),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text('Chat error:\n$_error'),
          ),
        ),
      );
    }

    final threadId = _threadId!;
    final stream = supabase
        .from('chat_messages')
        .stream(primaryKey: ['id'])
        .eq('thread_id', threadId)
        .order('created_at');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat'),
        leading: BackButton(onPressed: () => context.pop()),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: stream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Stream error:\n${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final msgs = snapshot.data!;
                if (msgs.isEmpty) {
                  return const Center(child: Text('Say hello 👋'));
                }

                final me = supabase.auth.currentUser?.id;

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: msgs.length,
                  itemBuilder: (context, i) {
                    final m = msgs[i];
                    final mine = (m['sender_user_id']?.toString() == me);
                    final body = (m['body'] ?? '').toString();

                    return Align(
                      alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: mine ? Colors.blue.withOpacity(0.15) : Colors.black.withOpacity(0.06),
                        ),
                        child: Text(body),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _ctrl,
                      decoration: const InputDecoration(
                        hintText: 'Message...',
                        border: OutlineInputBorder(),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
