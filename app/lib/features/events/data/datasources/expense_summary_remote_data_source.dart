import '../models/expense_summary_models.dart';

abstract class ExpenseSummaryRemoteDataSource {
  Future<List<UserExpenseSummaryModel>> getUserPendingExpenses(String userId);
  Future<GroupExpenseSummaryModel> getGroupExpenseSummary(String userId, String groupId);
}