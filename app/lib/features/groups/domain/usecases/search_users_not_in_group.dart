import 'package:app/core/error/failures.dart';
import 'package:app/core/usecase/usecase.dart';
import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'package:app/features/groups/domain/repositories/group_repository.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SearchUsersNotInGroup implements UseCase<List<UserProfile>, SearchUsersNotInGroupParams> {
  final GroupRepository repository;

  SearchUsersNotInGroup(this.repository);

  @override
  Future<Either<Failure, List<UserProfile>>> call(SearchUsersNotInGroupParams params) async {
    try {
      final users = await repository.searchUsersNotInGroup(params.query, params.groupId);
      return Right(users);
    } catch (e) {
      return Left(ServerFailure('Failed to search users: $e'));
    }
  }
}

class SearchUsersNotInGroupParams extends Equatable {
  final String query;
  final String groupId;

  const SearchUsersNotInGroupParams({required this.query, required this.groupId});

  @override
  List<Object> get props => [query, groupId];
}
