import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/group_expense_summary.dart';
import '../repositories/expense_summary_repository.dart';

class GetGroupExpenseSummary implements UseCase<GroupExpenseSummary, GetGroupExpenseSummaryParams> {
  final ExpenseSummaryRepository repository;

  GetGroupExpenseSummary(this.repository);

  @override
  Future<Either<Failure, GroupExpenseSummary>> call(GetGroupExpenseSummaryParams params) async {
    try {
      final summary = await repository.getGroupExpenseSummary(params.userId, params.groupId);
      return Right(summary);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}

class GetGroupExpenseSummaryParams {
  final String userId;
  final String groupId;

  GetGroupExpenseSummaryParams({required this.userId, required this.groupId});
}