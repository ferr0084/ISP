import '../../domain/entities/group_expense_summary.dart';
import '../../domain/entities/user_expense_summary.dart';
import '../../domain/repositories/expense_summary_repository.dart';
import '../datasources/expense_summary_remote_data_source.dart';

class ExpenseSummaryRepositoryImpl implements ExpenseSummaryRepository {
  final ExpenseSummaryRemoteDataSource remoteDataSource;

  ExpenseSummaryRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<UserExpenseSummary>> getUserPendingExpenses(String userId) async {
    final models = await remoteDataSource.getUserPendingExpenses(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<GroupExpenseSummary> getGroupExpenseSummary(
    String userId,
    String groupId,
  ) async {
    final model = await remoteDataSource.getGroupExpenseSummary(
      userId,
      groupId,
    );
    return model.toEntity();
  }
}
