import 'package:equatable/equatable.dart';

class GameParticipantModel extends Equatable {
  final int id;
  final String gameId;
  final String playerId;
  final bool isLoser;

  const GameParticipantModel({
    required this.id,
    required this.gameId,
    required this.playerId,
    required this.isLoser,
  });

  factory GameParticipantModel.fromJson(Map<String, dynamic> json) {
    return GameParticipantModel(
      id: json['id'] as int,
      gameId: json['game_id'] as String,
      playerId: json['player_id'] as String,
      isLoser: json['is_loser'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'player_id': playerId,
      'is_loser': isLoser,
    };
  }

  @override
  List<Object?> get props => [id, gameId, playerId, isLoser];
}
