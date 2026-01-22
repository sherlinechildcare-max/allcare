class ChatThread {
  final String id;
  final String title;
  final String lastMessage;
  final DateTime updatedAt;
  final int unread;

  ChatThread({
    required this.id,
    required this.title,
    required this.lastMessage,
    required this.updatedAt,
    required this.unread,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final bool fromMe;
  final DateTime sentAt;

  ChatMessage({
    required this.id,
    required this.text,
    required this.fromMe,
    required this.sentAt,
  });
}
