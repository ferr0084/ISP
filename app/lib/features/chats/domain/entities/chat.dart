import 'package:equatable/equatable.dart';

class Chat extends Equatable {
  final String id;
  final String? name;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Chat({
    required this.id,
    this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, name, createdAt, updatedAt];
}
