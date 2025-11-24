class FriendStatus {
  final String id;
  final String name;
  final String? avatarUrl;
  final bool isOnline;
  final DateTime? lastActiveAt;

  FriendStatus({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.isOnline = false,
    this.lastActiveAt,
  });
}
