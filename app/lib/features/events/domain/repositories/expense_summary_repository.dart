import '../entities/group_expense_summary.dart';
import '../entities/user_expense_summary.dart';

abstract class ExpenseSummaryRepository {
  Future<List<UserExpenseSummary>> getUserPendingExpenses(String userId);
  Future<GroupExpenseSummary> getGroupExpenseSummary(String userId, String groupId);
}