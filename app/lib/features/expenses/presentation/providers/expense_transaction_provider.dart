import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/expense_transaction.dart';
import '../../domain/usecases/get_user_expense_transactions.dart';

class ExpenseTransactionProvider with ChangeNotifier {
  final GetUserExpenseTransactions _getUserExpenseTransactions;

  ExpenseTransactionProvider(this._getUserExpenseTransactions);

  List<ExpenseTransaction> _transactions = [];
  bool _isLoading = false;
  String? _error;

  List<ExpenseTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  double get totalExpenses => _transactions
      .where((t) => !t.isOwed) // Money user owes (negative amounts)
      .fold(0.0, (sum, t) => sum + t.amount.abs());

  double get totalOwed => _transactions
      .where((t) => t.isOwed) // Money owed to user (positive amounts)
      .fold(0.0, (sum, t) => sum + t.amount);

  Future<void> fetchUserExpenseTransactions(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getUserExpenseTransactions(userId);
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          _error = failure.message;
        } else {
          _error = 'An error occurred';
        }
        _transactions = [];
      },
      (transactions) {
        _transactions = transactions;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _transactions = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}