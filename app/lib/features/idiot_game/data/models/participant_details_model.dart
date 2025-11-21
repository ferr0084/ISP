import 'package:app/features/idiot_game/domain/entities/participant_details.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';

class ParticipantDetailsModel extends ParticipantDetails {
  const ParticipantDetailsModel({
    required super.id,
    required super.gameId,
    required super.userId,
    required super.isLoser,
    required super.userProfile,
  });

  factory ParticipantDetailsModel.fromJson(Map<String, dynamic> json) {
    return ParticipantDetailsModel(
      id: json['id'] as int,
      gameId: json['game_id'] as String,
      userId: json['user_id'] as String,
      isLoser: json['is_loser'] as bool,
      userProfile: UserProfile.fromJson(
        json['profiles'] as Map<String, dynamic>,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'game_id': gameId,
      'user_id': userId,
      'is_loser': isLoser,
    };
  }
}
