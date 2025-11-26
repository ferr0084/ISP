import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/expense_transaction_model.dart';
import 'expense_remote_data_source.dart';

class ExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SupabaseClient supabaseClient;

  ExpenseRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<ExpenseTransactionModel>> getUserExpenseTransactions(String userId) async {
    final response = await supabaseClient.rpc('get_user_expense_transactions', params: {
      'p_user_id': userId,
    });

    return (response as List)
        .map((e) => ExpenseTransactionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}