import 'package:equatable/equatable.dart';

class Notification extends Equatable {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final Map<String, dynamic>? data;
  final bool read;
  final DateTime createdAt;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.data,
    required this.read,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    type,
    title,
    message,
    data,
    read,
    createdAt,
  ];
}
