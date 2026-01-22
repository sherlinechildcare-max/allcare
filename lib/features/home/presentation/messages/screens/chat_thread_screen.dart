import 'dart:async';
import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/chat_thread.dart';
import '../widgets/message_bubble.dart';

class ChatThreadScreen extends StatefulWidget {
  final ChatThread thread;

  const ChatThreadScreen({super.key, required this.thread});

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final _input = TextEditingController();
  final _scroll = ScrollController();

  late String _displayName;
  late bool _isOnline;

  bool _otherTyping = false;

  final List<ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _displayName = widget.thread.name;
    _isOnline = widget.thread.isOnline;

    // Seed UI-only messages
    _messages.addAll([
      ChatMessage(
        id: 'm1',
        text: 'Hi 👋 I saw your request. I can help.',
        at: DateTime.now().subtract(const Duration(minutes: 18)),
        fromMe: false,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm2',
        text: 'Great! Are you available tomorrow morning?',
        at: DateTime.now().subtract(const Duration(minutes: 16)),
        fromMe: true,
        status: MessageStatus.read,
      ),
      ChatMessage(
        id: 'm3',
        text: 'Yes ✅ What time works for you?',
        at: DateTime.now().subtract(const Duration(minutes: 14)),
        fromMe: false,
        status: MessageStatus.read,
      ),
    ]);

    // Simulate presence changes (UI-only)
    Timer.periodic(const Duration(seconds: 12), (t) {
      if (!mounted) return;
      setState(() => _isOnline = !_isOnline);
    });
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scroll.hasClients) return;
      _scroll.animateTo(
        _scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  void _send() async {
    final text = _input.text.trim();
    if (text.isEmpty) return;

    _input.clear();

    final sending = ChatMessage(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      text: text,
      at: DateTime.now(),
      fromMe: true,
      status: MessageStatus.sending,
    );

    setState(() => _messages.add(sending));
    _scrollToBottom();

    // simulate: sending -> sent -> delivered -> read
    await Future<void>.delayed(const Duration(milliseconds: 450));
    if (!mounted) return;
    setState(() => _replaceStatus(sending.id, MessageStatus.sent));

    await Future<void>.delayed(const Duration(milliseconds: 650));
    if (!mounted) return;
    setState(() => _replaceStatus(sending.id, MessageStatus.delivered));

    await Future<void>.delayed(const Duration(milliseconds: 750));
    if (!mounted) return;
    setState(() => _replaceStatus(sending.id, MessageStatus.read));

    // simulate other typing + reply
    setState(() => _otherTyping = true);
    _scrollToBottom();

    await Future<void>.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    setState(() => _otherTyping = false);

    final reply = ChatMessage(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      text: 'Sounds good. I’m available 👍',
      at: DateTime.now(),
      fromMe: false,
      status: MessageStatus.read,
    );
    setState(() => _messages.add(reply));
    _scrollToBottom();
  }

  void _replaceStatus(String id, MessageStatus s) {
    final i = _messages.indexWhere((m) => m.id == id);
    if (i < 0) return;
    final m = _messages[i];
    _messages[i] = ChatMessage(
      id: m.id,
      text: m.text,
      at: m.at,
      fromMe: m.fromMe,
      status: s,
    );
  }

  Future<void> _editName() async {
    final controller = TextEditingController(text: _displayName);
    final newName = await showModalBottomSheet<String>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 8,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit name', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'Display name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (newName != null && newName.isNotEmpty && mounted) {
      setState(() => _displayName = newName);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 40,
        titleSpacing: 0,
        title: InkWell(
          onTap: _editName,
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Colors.blueGrey.shade100,
                child: Text(widget.thread.initials.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _displayName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      _otherTyping ? 'typing…' : (_isOnline ? 'online' : 'offline'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Call',
            icon: const Icon(Icons.call_outlined),
            onPressed: () => _snack('Call (UI-only placeholder)'),
          ),
          IconButton(
            tooltip: 'Video',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: () => _snack('Video call (UI-only placeholder)'),
          ),
          PopupMenuButton<String>(
            onSelected: (v) => _snack(v),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'View contact', child: Text('View contact')),
              PopupMenuItem(value: 'Search', child: Text('Search')),
              PopupMenuItem(value: 'Mute', child: Text('Mute notifications')),
              PopupMenuItem(value: 'Clear chat', child: Text('Clear chat')),
              PopupMenuItem(value: 'Block', child: Text('Block')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemCount: _messages.length + (_otherTyping ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_otherTyping && i == _messages.length) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Text('typing…'),
                        ),
                      ],
                    ),
                  );
                }
                return MessageBubble(msg: _messages[i]);
              },
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Emoji',
                    icon: const Icon(Icons.emoji_emotions_outlined),
                    onPressed: () => _snack('Emoji picker (UI-only placeholder)'),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 5,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Attach',
                    icon: const Icon(Icons.attach_file),
                    onPressed: () => _snack('Attach (UI-only placeholder)'),
                  ),
                  const SizedBox(width: 4),
                  FloatingActionButton.small(
                    onPressed: _send,
                    child: const Icon(Icons.send),
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
