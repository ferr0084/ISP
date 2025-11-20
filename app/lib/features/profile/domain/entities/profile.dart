import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  final String id;
  final String? avatarUrl;
  final String fullName;
  final String? nickname;
  final String? phoneNumber;
  final String? about;
  final List<String>? badges;
  final Map<String, dynamic>? stats;
  final Map<String, dynamic>? notificationPreferences;

  const Profile({
    required this.id,
    this.avatarUrl,
    required this.fullName,
    this.nickname,
    this.phoneNumber,
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
    nickname,
    phoneNumber,
    about,
    badges,
    stats,
    notificationPreferences,
  ];

  Profile copyWith({
    String? id,
    String? avatarUrl,
    String? fullName,
    String? nickname,
    String? phoneNumber,
    String? about,
    List<String>? badges,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? notificationPreferences,
  }) {
    return Profile(
      id: id ?? this.id,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      fullName: fullName ?? this.fullName,
      nickname: nickname ?? this.nickname,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      about: about ?? this.about,
      badges: badges ?? this.badges,
      stats: stats ?? this.stats,
      notificationPreferences:
          notificationPreferences ?? this.notificationPreferences,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'avatar_url': avatarUrl,
      'full_name': fullName,
      'nickname': nickname,
      'phone_number': phoneNumber,
      'about': about,
      'badges': badges,
      'stats': stats,
      'notification_preferences': notificationPreferences,
    };
  }

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      avatarUrl: map['avatar_url'],
      fullName: map['full_name'] ?? '',
      nickname: map['nickname'],
      phoneNumber: map['phone_number'],
      about: map['about'],
      badges: map['badges'] != null ? List<String>.from(map['badges']) : null,
      stats: map['stats'] != null
          ? Map<String, dynamic>.from(map['stats'])
          : null,
      notificationPreferences: map['notification_preferences'] != null
          ? Map<String, dynamic>.from(map['notification_preferences'])
          : null,
    );
  }

  @override
  String toString() =>
      'Profile(id: $id, avatarUrl: $avatarUrl, fullName: $fullName, nickname: $nickname, phoneNumber: $phoneNumber, about: $about, badges: $badges, stats: $stats, notificationPreferences: $notificationPreferences)';
}
