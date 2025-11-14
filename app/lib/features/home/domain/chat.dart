class Chat {
  final String name;
  final String lastMessage;
  final String avatarUrl;
  final String time;
  final int unreadCount;
  final bool isOnline;

  Chat({
    required this.name,
    required this.lastMessage,
    required this.avatarUrl,
    required this.time,
    this.unreadCount = 0,
    this.isOnline = false,
  });
}
