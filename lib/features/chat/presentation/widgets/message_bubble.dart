import 'package:flutter/material.dart';
import '../../domain/chat_models.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isMe = message.fromMe;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isMe
              ? Theme.of(context).colorScheme.primary.withOpacity(0.15)
              : Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(message.text),
      ),
    );
  }
}
