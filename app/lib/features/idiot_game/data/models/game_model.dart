import 'package:app/features/idiot_game/domain/entities/game.dart';

class GameModel extends Game {
  const GameModel({
    required super.id,
    required super.gameDate,
    super.createdBy,
    super.description,
  });

  factory GameModel.fromJson(Map<String, dynamic> json) {
    return GameModel(
      id: json['id'] as String,
      gameDate: DateTime.parse(json['game_date'] as String),
      createdBy: json['created_by'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_date': gameDate.toIso8601String(),
      'created_by': createdBy,
      'description': description,
    };
  }
}
