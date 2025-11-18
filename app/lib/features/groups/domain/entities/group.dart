import 'package:equatable/equatable.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final String avatarUrl;
  final List<String> memberIds;
  final String lastMessage;
  final DateTime time; // Changed from String to DateTime
  final int? unreadCount;
  final String? chatId;

  const Group({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.memberIds,
    required this.lastMessage,
    required this.time,
    this.unreadCount,
    this.chatId,
  });

  // copyWith method
  Group copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    List<String>? memberIds,
    String? lastMessage,
    DateTime? time,
    int? unreadCount,
    String? chatId,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      memberIds: memberIds ?? this.memberIds,
      lastMessage: lastMessage ?? this.lastMessage,
      time: time ?? this.time,
      unreadCount: unreadCount ?? this.unreadCount,
      chatId: chatId ?? this.chatId,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    avatarUrl,
    memberIds,
    lastMessage,
    time,
    unreadCount,
    chatId,
  ];
}
