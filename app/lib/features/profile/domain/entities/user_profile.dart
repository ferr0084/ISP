import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String? avatarUrl;
  final String? fullName;
  final String? email;
  final String? nickname;
  final String? about;
  final List<String>? badges;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? notificationPreferences;

  const UserProfile({
    required this.id,
    this.avatarUrl,
    this.fullName,
    this.email,
    this.nickname,
    this.about,
    this.badges,
    this.stats,
    this.notificationPreferences,
  });

  @override
  List<Object?> get props => [
    id,
    avatarUrl,
    fullName,
    email,
    nickname,
    about,
    badges,
    stats,
    notificationPreferences,
  ];

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      avatarUrl: json['avatar_url'] as String?,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      nickname: json['nickname'] as String?,
      about: json['about'] as String?,
      badges: json['badges'] != null ? List<String>.from(json['badges']) : null,
      stats: json['stats'] != null
          ? Map<String, dynamic>.from(json['stats'])
          : null,
      notificationPreferences: json['notification_preferences'] != null
          ? Map<String, dynamic>.from(json['notification_preferences'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatar_url': avatarUrl,
      'full_name': fullName,
      'email': email,
      'nickname': nickname,
      'about': about,
      'badges': badges,
      'stats': stats,
      'notification_preferences': notificationPreferences,
    };
  }
}
