import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/friend_status.dart';
import '../../domain/repositories/friend_status_repository.dart';

class FriendStatusRepositoryImpl implements FriendStatusRepository {
  final SupabaseClient supabaseClient;

  FriendStatusRepositoryImpl(this.supabaseClient);

  @override
  Future<Either<Failure, List<FriendStatus>>> getFriendStatuses() async {
    try {
      // Fetch profiles, ordered by last_seen descending
      final response = await supabaseClient
          .from('profiles')
          .select()
          .order('last_seen', ascending: false)
          .limit(20); // Limit to recent 20 for now

      final List<FriendStatus> statuses = (response as List).map((json) {
        final lastSeenStr = json['last_seen'] as String?;
        final lastSeen = lastSeenStr != null
            ? DateTime.parse(lastSeenStr)
            : null;

        // Infer online status: active within last 15 minutes
        final isOnline =
            lastSeen != null &&
            DateTime.now().difference(lastSeen).inMinutes < 15;

        return FriendStatus(
          id: json['id'],
          name: json['full_name'] ?? 'Unknown',
          avatarUrl: json['avatar_url'],
          isOnline: isOnline,
          lastActiveAt: lastSeen,
        );
      }).toList();

      return Right(statuses);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
