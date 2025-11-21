import 'package:equatable/equatable.dart';

class UserStats extends Equatable {
  final int totalGames;
  final double winRate;
  final int currentStreak;
  final String streakType; // 'win' or 'loss'

  const UserStats({
    required this.totalGames,
    required this.winRate,
    required this.currentStreak,
    required this.streakType,
  });

  @override
  List<Object?> get props => [totalGames, winRate, currentStreak, streakType];
}
