enum MessageStatus { sending, sent, delivered, read }

class ChatMessage {
  final String id;
  final String text;
  final DateTime at;
  final bool fromMe;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.at,
    required this.fromMe,
    this.status = MessageStatus.sent,
  });
}
