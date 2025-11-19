import 'package:equatable/equatable.dart';

class GroupMember extends Equatable {
  final String userId;
  final String name;
  final String? avatarUrl;
  final String email;
  final DateTime joinedAt;
  final String role; // 'admin', 'member'

  const GroupMember({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.email,
    required this.joinedAt,
    this.role = 'member',
  });

  @override
  List<Object?> get props => [userId, name, avatarUrl, email, joinedAt, role];
}
