import '../models/expense_transaction_model.dart';

abstract class ExpenseRemoteDataSource {
  Future<List<ExpenseTransactionModel>> getUserExpenseTransactions(String userId);
}