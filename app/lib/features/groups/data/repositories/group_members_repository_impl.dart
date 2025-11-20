import 'package:app/core/error/failures.dart';
import 'package:app/features/groups/data/datasources/group_members_remote_data_source.dart';
import 'package:app/features/groups/domain/entities/group_member.dart';
import 'package:app/features/groups/domain/repositories/group_members_repository.dart';
import 'package:dartz/dartz.dart';

class GroupMembersRepositoryImpl implements GroupMembersRepository {
  final GroupMembersRemoteDataSource remoteDataSource;

  GroupMembersRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<GroupMember>>> getGroupMembers(
    String groupId,
  ) async {
    try {
      final groupMembers = await remoteDataSource.getGroupMembers(groupId);
      return Right(groupMembers);
    } on Exception catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
