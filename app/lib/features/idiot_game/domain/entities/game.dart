import 'package:equatable/equatable.dart';

class Game extends Equatable {
  final String id;
  final DateTime gameDate;
  final String? createdBy;
  final String? description;

  const Game({
    required this.id,
    required this.gameDate,
    this.createdBy,
    this.description,
  });

  @override
  List<Object?> get props => [id, gameDate, createdBy, description];
}
