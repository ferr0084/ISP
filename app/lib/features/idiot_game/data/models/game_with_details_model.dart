import 'package:app/features/idiot_game/data/models/game_model.dart';
import 'package:app/features/idiot_game/data/models/participant_details_model.dart';
import 'package:app/features/idiot_game/domain/entities/game_with_details.dart';

class GameWithDetailsModel extends GameWithDetails {
  const GameWithDetailsModel({
    required super.game,
    required super.participants,
  });

  factory GameWithDetailsModel.fromJson(Map<String, dynamic> json) {
    final game = GameModel.fromJson(json);

    final participantsList = json['idiot_game_participants'] as List?;
    final participants = participantsList != null
        ? participantsList
              .map(
                (p) =>
                    ParticipantDetailsModel.fromJson(p as Map<String, dynamic>),
              )
              .toList()
        : <ParticipantDetailsModel>[];

    return GameWithDetailsModel(game: game, participants: participants);
  }

  Map<String, dynamic> toJson() {
    final gameJson = (game as GameModel).toJson();
    gameJson['idiot_game_participants'] = participants
        .map((p) => (p as ParticipantDetailsModel).toJson())
        .toList();
    return gameJson;
  }
}
