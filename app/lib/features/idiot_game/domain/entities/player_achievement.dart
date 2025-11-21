import 'package:equatable/equatable.dart';

class PlayerAchievement extends Equatable {
  final int id;
  final String playerId;
  final int achievementId;
  final DateTime unlockedAt;

  const PlayerAchievement({
    required this.id,
    required this.playerId,
    required this.achievementId,
    required this.unlockedAt,
  });

  @override
  List<Object?> get props => [id, playerId, achievementId, unlockedAt];
}
