class Profile {
  final String id;
  final String fullName;
  final String? phoneNumber;

  const Profile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
  });

  Profile copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
  }) {
    return Profile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'phone_number': phoneNumber,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      phoneNumber: map['phone_number'],
    );
  }

  @override
  String toString() =>
      'Profile(id: $id, fullName: $fullName, phoneNumber: $phoneNumber)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Profile &&
        other.id == id &&
        other.fullName == fullName &&
        other.phoneNumber == phoneNumber;
  }

  @override
  int get hashCode => id.hashCode ^ fullName.hashCode ^ phoneNumber.hashCode;
}
