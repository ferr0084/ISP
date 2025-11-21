import 'package:app/features/idiot_game/domain/entities/game.dart';
import 'package:app/features/idiot_game/domain/entities/participant_details.dart';
import 'package:equatable/equatable.dart';

class GameWithDetails extends Equatable {
  final Game game;
  final List<ParticipantDetails> participants;

  const GameWithDetails({required this.game, required this.participants});

  ParticipantDetails? get loser =>
      participants.where((p) => p.isLoser).firstOrNull;

  @override
  List<Object?> get props => [game, participants];
}
