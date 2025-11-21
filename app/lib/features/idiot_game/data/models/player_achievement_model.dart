import 'package:equatable/equatable.dart';

class PlayerAchievementModel extends Equatable {
  final int id;
  final String playerId;
  final int achievementId;
  final DateTime unlockedAt;

  const PlayerAchievementModel({
    required this.id,
    required this.playerId,
    required this.achievementId,
    required this.unlockedAt,
  });

  factory PlayerAchievementModel.fromJson(Map<String, dynamic> json) {
    return PlayerAchievementModel(
      id: json['id'] as int,
      playerId: json['player_id'] as String,
      achievementId: json['achievement_id'] as int,
      unlockedAt: DateTime.parse(json['unlocked_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'player_id': playerId,
      'achievement_id': achievementId,
      'unlocked_at': unlockedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, playerId, achievementId, unlockedAt];
}
