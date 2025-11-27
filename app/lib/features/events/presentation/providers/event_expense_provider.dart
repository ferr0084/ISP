import 'package:flutter/foundation.dart';

import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/domain/repositories/contact_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/entities/settlement.dart';
import '../../domain/usecases/create_expense.dart';
import '../../domain/usecases/create_settlement.dart';
import '../../domain/usecases/get_event_expenses.dart';

class EventExpenseProvider extends ChangeNotifier {
  final GetEventExpenses getEventExpenses;
  final CreateExpense createExpense;
  final CreateSettlement createSettlement;
  final ContactRepository contactRepository;

  EventExpenseProvider({
    required this.getEventExpenses,
    required this.createExpense,
    required this.createSettlement,
    required this.contactRepository,
  });

  List<EventExpense> _expenses = [];
  List<EventSettlement> _settlements = [];
  bool _isLoading = false;
  String? _error;

  List<EventExpense> get expenses => _expenses;
  List<EventSettlement> get settlements => _settlements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final Map<String, Contact> _contacts = {};

  String? getUserName(String userId) {
    final contact = _contacts[userId];
    if (contact == null) return null;
    return contact.nickname?.isNotEmpty == true
        ? contact.nickname
        : contact.name;
  }

  Future<void> fetchUserName(String userId) async {
    if (_contacts.containsKey(userId)) return;

    try {
      final contact = await contactRepository.getContact(userId);
      _contacts[userId] = contact;
      notifyListeners();
    } catch (e) {
      // Ignore error
    }
  }

  // Calculate balances: userId -> amount (positive = owed to user, negative = user owes)
  Map<String, double> get balances {
    final balances = <String, double>{};

    // Process expenses
    for (final expense in _expenses) {
      // Payer gets positive balance (they paid, so they are owed)
      balances[expense.payerId] =
          (balances[expense.payerId] ?? 0) + expense.amount;

      // Participants get negative balance (they owe)
      if (expense.participants != null) {
        for (final participant in expense.participants!) {
          balances[participant.userId] =
              (balances[participant.userId] ?? 0) - participant.amountOwed;
        }
      }
    }

    // Process settlements
    for (final settlement in _settlements) {
      // Payer (who paid back) gets positive balance (debt reduced/paid)
      // Wait, if I pay you back, my balance should increase (become less negative)
      // And your balance should decrease (become less positive)

      // Let's trace:
      // Alice pays $100 for lunch. Alice: +100. Bob: -50, Charlie: -50.
      // Bob pays Alice $50.
      // Bob's balance should go from -50 to 0. So +50.
      // Alice's balance should go from +100 to +50. So -50.

      balances[settlement.payerId] =
          (balances[settlement.payerId] ?? 0) + settlement.amount;
      balances[settlement.payeeId] =
          (balances[settlement.payeeId] ?? 0) - settlement.amount;
    }

    return balances;
  }

  Future<void> loadExpenses(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await getEventExpenses(eventId);
      _expenses = result.expenses;
      _settlements = result.settlements;

      // Fetch user names
      final userIds = <String>{};
      for (final expense in _expenses) {
        userIds.add(expense.payerId);
        if (expense.participants != null) {
          for (final p in expense.participants!) {
            userIds.add(p.userId);
          }
        }
      }
      for (final settlement in _settlements) {
        userIds.add(settlement.payerId);
        userIds.add(settlement.payeeId);
      }

      for (final userId in userIds) {
        fetchUserName(userId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newExpense = await createExpense(
        eventId: eventId,
        payerId: payerId,
        amount: amount,
        description: description,
        participants: participants,
      );
      _expenses.insert(0, newExpense);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> settleUp({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newSettlement = await createSettlement(
        eventId: eventId,
        payerId: payerId,
        payeeId: payeeId,
        amount: amount,
      );
      _settlements.insert(0, newSettlement);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
