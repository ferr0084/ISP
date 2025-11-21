import 'package:app/features/idiot_game/domain/entities/user_stats.dart';

class UserStatsModel extends UserStats {
  const UserStatsModel({
    required super.totalGames,
    required super.winRate,
    required super.currentStreak,
    required super.streakType,
  });

  factory UserStatsModel.fromJson(Map<String, dynamic> json) {
    return UserStatsModel(
      totalGames: json['total_games'] as int? ?? 0,
      winRate: (json['win_rate'] as num?)?.toDouble() ?? 0.0,
      currentStreak: json['current_streak'] as int? ?? 0,
      streakType: json['streak_type'] as String? ?? 'none',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_games': totalGames,
      'win_rate': winRate,
      'current_streak': currentStreak,
      'streak_type': streakType,
    };
  }
}
