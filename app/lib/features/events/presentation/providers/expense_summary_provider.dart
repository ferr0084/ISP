import 'package:flutter/material.dart';

import '../../../../core/error/failures.dart';
import '../../domain/usecases/get_user_pending_expenses.dart';
import '../../domain/entities/user_expense_summary.dart';

class ExpenseSummaryProvider with ChangeNotifier {
  final GetUserPendingExpenses _getUserPendingExpenses;

  ExpenseSummaryProvider(this._getUserPendingExpenses);

  List<UserExpenseSummary> _pendingExpenses = [];
  bool _isLoading = false;
  String? _error;

  List<UserExpenseSummary> get pendingExpenses => _pendingExpenses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchUserPendingExpenses(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getUserPendingExpenses(userId);
    result.fold(
      (failure) {
        if (failure is ServerFailure) {
          _error = failure.message;
        } else {
          _error = 'An error occurred';
        }
        _pendingExpenses = [];
      },
      (expenses) {
        _pendingExpenses = expenses;
        _error = null;
      },
    );

    _isLoading = false;
    notifyListeners();
  }

  void clearData() {
    _pendingExpenses = [];
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}