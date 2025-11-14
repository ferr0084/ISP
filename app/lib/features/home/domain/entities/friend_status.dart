

class FriendStatus {
  final String name;
  final String avatarUrl;
  final bool isOnline;

  FriendStatus({
    required this.name,
    required this.avatarUrl,
    this.isOnline = false,
  });
}