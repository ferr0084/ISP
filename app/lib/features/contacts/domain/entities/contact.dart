class Contact {
  final String id;
  final String name;
  final String avatarUrl;
  final String status;
  final bool isOnline;

  Contact({
    required this.id,
    required this.name,
    required this.avatarUrl,
    this.status = 'last seen recently',
    this.isOnline = false,
  });

  factory Contact.fromProfile({
    required Map<String, dynamic> profile,
    String status = 'last seen recently',
    bool isOnline = false,
  }) {
    return Contact(
      id: profile['id'],
      name: profile['full_name'],
      avatarUrl: profile['avatar_url'],
      status: status,
      isOnline: isOnline,
    );
  }
}
