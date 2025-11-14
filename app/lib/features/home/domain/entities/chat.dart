class Chat {
  final String senderName;
  final String avatarUrl;
  final String message;
  final String time; // e.g., "10:42 AM", "Yesterday"
  final int? unreadCount;

  Chat({
    required this.senderName,
    required this.avatarUrl,
    required this.message,
    required this.time,
    this.unreadCount,
  });
}
