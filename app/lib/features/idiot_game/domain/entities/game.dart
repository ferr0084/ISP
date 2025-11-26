import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String id;
  final DateTime gameDate;
  final String? createdBy;
  final String? description;
  final String? groupId;
  final String? imageUrl;

  const Game({
    required this.id,
    required this.gameDate,
    this.createdBy,
    this.description,
    this.groupId,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [id, gameDate, createdBy, description, groupId, imageUrl];
}
