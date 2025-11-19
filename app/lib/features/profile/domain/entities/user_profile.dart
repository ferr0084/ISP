import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final String? email; // Added email field

  const UserProfile({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.email,
  });

  @override
  List<Object?> get props => [id, fullName, avatarUrl, email];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'email': email,
    };
  }
}
