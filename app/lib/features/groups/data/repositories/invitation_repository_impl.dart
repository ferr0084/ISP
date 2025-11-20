import 'package:app/core/error/failures.dart';
import 'package:app/features/groups/domain/repositories/invitation_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class InvitationRepositoryImpl implements InvitationRepository {
  final SupabaseClient _supabaseClient;

  InvitationRepositoryImpl(this._supabaseClient);

  @override
  Future<Either<Failure, void>> sendGroupInvite({
    required String inviterId,
    required String inviteeEmail,
    required String groupId,
  }) async {
    try {
      final response = await _supabaseClient.functions.invoke(
        'send-invite',
        body: {
          'inviter_id': inviterId,
          'invitee_email': inviteeEmail,
          'group_id': groupId,
        },
      );
      if (response.status != 200) {
        return Left(
          ServerFailure(
            response.data['error'] ?? 'Failed to send group invitation',
          ),
        );
      }
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure('Error sending group invitation: $e'));
    }
  }

  @override
  Future<void> acceptInvite(String token, String userId) async {
    print(
      'InvitationRepositoryImpl: acceptInvite called with token: $token, userId: $userId',
    );
    try {
      print('InvitationRepositoryImpl: invoking accept-invite function');
      final response = await _supabaseClient.functions.invoke(
        'accept-invite',
        body: {'token': token, 'user_id': userId},
      );
      print(
        'InvitationRepositoryImpl: accept-invite response status: ${response.status}',
      );
      if (response.status != 200) {
        print(
          'InvitationRepositoryImpl: accept-invite error data: ${response.data}',
        );
        throw Exception(
          response.data['error'] ?? 'Failed to accept invitation',
        );
      }
      print('InvitationRepositoryImpl: accept-invite success');
    } catch (e) {
      print('InvitationRepositoryImpl: accept-invite exception: $e');
      throw Exception('Error accepting invitation: $e');
    }
  }
}
