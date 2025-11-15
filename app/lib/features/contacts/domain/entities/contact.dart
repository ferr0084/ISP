class Contact {
  final String id;
  final String name;
  final String? avatarUrl; // Made nullable
  final String? phoneNumber; // Added
  final String? email; // Added
  final String? nickname; // Added
  final String status;
  final bool isOnline;

  Contact({
    required this.id,
    required this.name,
    this.avatarUrl, // Made optional
    this.phoneNumber, // Added
    this.email, // Added
    this.nickname, // Added
    this.status = 'last seen recently',
    this.isOnline = false,
  });

  // Add copyWith method
  Contact copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? phoneNumber,
    String? email,
    String? nickname,
    String? status,
    bool? isOnline,
  }) {
    return Contact(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  factory Contact.fromProfile({
    required Map<String, dynamic> profile,
    String status = 'last seen recently',
    bool isOnline = false,
  }) {
    return Contact(
      id: profile['id'],
      name: profile['full_name'],
      avatarUrl: profile['avatar_url'],
      phoneNumber: profile['phone_number'], // Added
      email: profile['email'], // Added
      nickname: profile['nickname'], // Added
      status: status,
      isOnline: isOnline,
    );
  }
}
