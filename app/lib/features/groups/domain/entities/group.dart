class Group {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> memberIds;
  final String lastMessage;
  final String time;
  final int? unreadCount;

  Group({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.memberIds,
    required this.lastMessage,
    required this.time,
    this.unreadCount,
  });
}
