import 'package:equatable/equatable.dart';

class GameParticipant extends Equatable {
  final int id;
  final String gameId;
  final String userId;
  final bool isLoser;

  const GameParticipant({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.isLoser,
  });

  @override
  List<Object?> get props => [id, gameId, userId, isLoser];
}
