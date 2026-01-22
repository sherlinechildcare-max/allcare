class ChatThread {
  final String id;
  final String name;
  final String subtitle;
  final String lastMessage;
  final String timeLabel;
  final int unreadCount;
  final bool isOnline;
  final bool isPinned;

  const ChatThread({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.lastMessage,
    required this.timeLabel,
    this.unreadCount = 0,
    this.isOnline = false,
    this.isPinned = false,
  });

  String get initials {
    final parts = name.trim().split(RegExp(r"\s+"));
    final first = parts.isNotEmpty ? parts.first : "";
    final last = parts.length > 1 ? parts.last : "";
    return (first.isNotEmpty ? first[0] : "") +
           (last.isNotEmpty ? last[0] : "");
  }
}
