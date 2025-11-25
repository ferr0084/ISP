import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/expense_model.dart';
import '../models/settlement_model.dart';

abstract class EventExpenseRemoteDataSource {
  Future<List<EventExpenseModel>> getEventExpenses(String eventId);
  Future<List<EventSettlementModel>> getEventSettlements(String eventId);
  Future<EventExpenseModel> createExpense({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants,
  });
  Future<EventSettlementModel> createSettlement({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  });
}

class EventExpenseRemoteDataSourceImpl implements EventExpenseRemoteDataSource {
  final SupabaseClient supabaseClient;

  EventExpenseRemoteDataSourceImpl(this.supabaseClient);

  @override
  Future<List<EventExpenseModel>> getEventExpenses(String eventId) async {
    final response = await supabaseClient
        .from('event_expenses')
        .select('*, participants:event_expense_participants(*)')
        .eq('event_id', eventId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => EventExpenseModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<EventSettlementModel>> getEventSettlements(String eventId) async {
    final response = await supabaseClient
        .from('event_settlements')
        .select()
        .eq('event_id', eventId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((e) => EventSettlementModel.fromJson(e))
        .toList();
  }

  @override
  Future<EventExpenseModel> createExpense({
    required String eventId,
    required String payerId,
    required double amount,
    required String description,
    required Map<String, double> participants,
  }) async {
    // 1. Create expense
    final expenseResponse = await supabaseClient
        .from('event_expenses')
        .insert({
          'event_id': eventId,
          'payer_id': payerId,
          'amount': amount,
          'description': description,
        })
        .select()
        .single();

    final expenseId = expenseResponse['id'] as String;

    // 2. Create participants
    final participantsData = participants.entries.map((entry) {
      return {
        'expense_id': expenseId,
        'user_id': entry.key,
        'amount_owed': entry.value,
      };
    }).toList();

    await supabaseClient
        .from('event_expense_participants')
        .insert(participantsData);

    // 3. Fetch complete expense with participants
    final fullExpenseResponse = await supabaseClient
        .from('event_expenses')
        .select('*, participants:event_expense_participants(*)')
        .eq('id', expenseId)
        .single();

    return EventExpenseModel.fromJson(fullExpenseResponse);
  }

  @override
  Future<EventSettlementModel> createSettlement({
    required String eventId,
    required String payerId,
    required String payeeId,
    required double amount,
  }) async {
    final response = await supabaseClient
        .from('event_settlements')
        .insert({
          'event_id': eventId,
          'payer_id': payerId,
          'payee_id': payeeId,
          'amount': amount,
        })
        .select()
        .single();

    return EventSettlementModel.fromJson(response);
  }
}
