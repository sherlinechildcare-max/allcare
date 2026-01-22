import 'package:flutter/material.dart';
import '../models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage msg;

  const MessageBubble({super.key, required this.msg});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(16);

    final bg = msg.fromMe ? theme.colorScheme.primaryContainer : Colors.grey.shade200;
    final align = msg.fromMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;

    IconData? statusIcon;
    if (msg.fromMe) {
      switch (msg.status) {
        case MessageStatus.sending:
          statusIcon = Icons.access_time;
          break;
        case MessageStatus.sent:
          statusIcon = Icons.check;
          break;
        case MessageStatus.delivered:
          statusIcon = Icons.done_all;
          break;
        case MessageStatus.read:
          statusIcon = Icons.done_all;
          break;
      }
    }

    final time = _fmtTime(msg.at);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Column(
        crossAxisAlignment: align,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(msg.text),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(time, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[700])),
                        if (msg.fromMe) ...[
                          const SizedBox(width: 6),
                          Icon(
                            statusIcon,
                            size: 16,
                            color: msg.status == MessageStatus.read ? theme.colorScheme.primary : Colors.grey[700],
                          ),
                        ]
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmtTime(DateTime dt) {
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final m = dt.minute.toString().padLeft(2, '0');
    final ap = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $ap';
  }
}
