import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense_summary_models.dart';
import 'expense_summary_remote_data_source.dart';

class ExpenseSummaryRemoteDataSourceImpl implements ExpenseSummaryRemoteDataSource {
  final SupabaseClient supabaseClient;

  ExpenseSummaryRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<UserExpenseSummaryModel>> getUserPendingExpenses(String userId) async {
    final response = await supabaseClient.rpc('get_user_pending_expenses', params: {
      'p_user_id': userId,
    });

    return (response as List)
        .map((e) => UserExpenseSummaryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<GroupExpenseSummaryModel> getGroupExpenseSummary(String userId, String groupId) async {
    final response = await supabaseClient.rpc('get_group_expense_summary', params: {
      'p_user_id': userId,
      'p_group_id': groupId,
    });

    return GroupExpenseSummaryModel.fromJson({'net_amount': response});
  }
}