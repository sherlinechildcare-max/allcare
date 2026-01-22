import 'dart:async';
import 'package:flutter/material.dart';
import 'contact_info_screen.dart';

class ChatThreadScreen extends StatefulWidget {
  final String threadId;
  final String initialName;
  final String phone;
  final String? avatarUrl;
  final bool isOnline;
  final String lastSeenLabel;

  const ChatThreadScreen({
    super.key,
    required this.threadId,
    required this.initialName,
    required this.phone,
    this.avatarUrl,
    required this.isOnline,
    required this.lastSeenLabel,
  });

  @override
  State<ChatThreadScreen> createState() => _ChatThreadScreenState();
}

class _ChatThreadScreenState extends State<ChatThreadScreen> {
  final TextEditingController _composer = TextEditingController();
  final ScrollController _scroll = ScrollController();

  late String _name;
  late bool _isOnline;
  late String _lastSeen;

  Timer? _presenceTimer;

  final List<_Msg> _messages = [
    _Msg(fromMe: false, text: 'Hi! Quick question before I head over.', time: '02:08'),
    _Msg(fromMe: true, text: 'Sure — what’s up?', time: '02:08'),
    _Msg(fromMe: false, text: 'What’s the parking situation?', time: '02:08'),
  ];

  @override
  void initState() {
    super.initState();
    _name = widget.initialName;
    _isOnline = widget.isOnline;
    _lastSeen = widget.lastSeenLabel;

    // Mock presence changes so it feels alive in UI mode.
    // Replace with Supabase presence later.
    _presenceTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      setState(() {
        _isOnline = !_isOnline;
        _lastSeen = _isOnline ? 'online' : 'last seen just now';
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  @override
  void dispose() {
    _presenceTimer?.cancel();
    _composer.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _jumpToBottom() {
    if (!_scroll.hasClients) return;
    _scroll.animateTo(
      _scroll.position.maxScrollExtent + 200,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = _isOnline ? 'online' : _lastSeen;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: InkWell(
          onTap: _openContactInfo,
          child: Row(
            children: [
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                child: Text(_initials(_name)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Audio call',
            icon: const Icon(Icons.call_outlined),
            onPressed: _startAudioCall,
          ),
          IconButton(
            tooltip: 'Video call',
            icon: const Icon(Icons.videocam_outlined),
            onPressed: _startVideoCall,
          ),
          PopupMenuButton<String>(
            onSelected: (v) => _onMenu(v),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'search', child: Text('Search')),
              PopupMenuItem(value: 'mute', child: Text('Mute notifications')),
              PopupMenuItem(value: 'clear', child: Text('Clear chat')),
              PopupMenuItem(value: 'block', child: Text('Block')),
              PopupMenuItem(value: 'report', child: Text('Report')),
              PopupMenuItem(value: 'info', child: Text('Contact info')),
              PopupMenuItem(value: 'edit_name', child: Text('Edit name')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, i) => _Bubble(msg: _messages[i]),
            ),
          ),
          _ComposerBar(
            controller: _composer,
            onSend: _send,
            onAttach: _attach,
            onCamera: _camera,
            onMic: _mic,
          ),
        ],
      ),
    );
  }

  void _send() {
    final text = _composer.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_Msg(fromMe: true, text: text, time: _nowTime()));
      _composer.clear();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _jumpToBottom());
  }

  String _nowTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  void _attach() {
    _toast('Attachments (docs/photos) will be enabled when we wire Supabase Storage.');
  }

  void _camera() {
    _toast('Camera upload will be enabled when we wire permissions + storage.');
  }

  void _mic() {
    _toast('Voice messages will be enabled later (we can store audio in Supabase).');
  }

  void _startAudioCall() {
    _toast('Audio call UI is ready. We can enable real calling later (WebRTC/Agora/Twilio).');
  }

  void _startVideoCall() {
    _toast('Video call UI is ready. We can enable real calling later (WebRTC/Agora/Twilio).');
  }

  void _openContactInfo() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ContactInfoScreen(
          name: _name,
          phone: widget.phone,
          isOnline: _isOnline,
          lastSeenLabel: _lastSeen,
          onEditName: (newName) => setState(() => _name = newName),
          onAudioCall: _startAudioCall,
          onVideoCall: _startVideoCall,
        ),
      ),
    );
  }

  void _onMenu(String v) {
    switch (v) {
      case 'info':
        _openContactInfo();
        break;
      case 'edit_name':
        _editNameDialog();
        break;
      default:
        _toast('Action: $v');
    }
  }

  Future<void> _editNameDialog() async {
    final c = TextEditingController(text: _name);
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
    if (res != null && res.isNotEmpty) {
      setState(() => _name = res);
    }
  }

  void _toast(String msg) {
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

class _Msg {
  final bool fromMe;
  final String text;
  final String time;
  _Msg({required this.fromMe, required this.text, required this.time});
}

class _Bubble extends StatelessWidget {
  final _Msg msg;
  const _Bubble({required this.msg});

  @override
  Widget build(BuildContext context) {
    final align = msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleAlign = msg.fromMe ? Alignment.centerRight : Alignment.centerLeft;

    final bg = msg.fromMe
        ? Theme.of(context).colorScheme.primary.withOpacity(0.14)
        : Theme.of(context).colorScheme.surfaceVariant;

    return Align(
      alignment: bubbleAlign,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 320),
          child: Column(
            crossAxisAlignment: align,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(msg.text),
              ),
              const SizedBox(height: 3),
              Text(msg.time, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

class _ComposerBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final VoidCallback onAttach;
  final VoidCallback onCamera;
  final VoidCallback onMic;

  const _ComposerBar({
    required this.controller,
    required this.onSend,
    required this.onAttach,
    required this.onCamera,
    required this.onMic,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
        child: Row(
          children: [
            IconButton(
              tooltip: 'Attach',
              icon: const Icon(Icons.attach_file),
              onPressed: onAttach,
            ),
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Message…',
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(999)),
                ),
              ),
            ),
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Camera',
              icon: const Icon(Icons.photo_camera_outlined),
              onPressed: onCamera,
            ),
            IconButton(
              tooltip: 'Mic',
              icon: const Icon(Icons.mic_none),
              onPressed: onMic,
            ),
            const SizedBox(width: 4),
            FilledButton(
              style: FilledButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(14)),
              onPressed: onSend,
              child: const Icon(Icons.send),
            ),
          ],
        ),
      ),
    );
  }
}
