import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:equatable/equatable.dart';

class ParticipantDetails extends Equatable {
  final int id;
  final String gameId;
  final String userId;
  final bool isLoser;
  final UserProfile userProfile;

  const ParticipantDetails({
    required this.id,
    required this.gameId,
    required this.userId,
    required this.isLoser,
    required this.userProfile,
  });

  @override
  List<Object?> get props => [id, gameId, userId, isLoser, userProfile];
}
