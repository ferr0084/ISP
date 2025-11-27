import '../../domain/entities/group_expense_summary.dart';
import '../../domain/entities/user_expense_summary.dart';

class UserExpenseSummaryModel {
  final String otherUserId;
  final String otherUserName;
  final double netAmount;
  final String eventName;
  final String expenseDescription;

  UserExpenseSummaryModel({
    required this.otherUserId,
    required this.otherUserName,
    required this.netAmount,
    required this.eventName,
    required this.expenseDescription,
  });

  factory UserExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return UserExpenseSummaryModel(
      otherUserId: json['other_user_id'] as String,
      otherUserName: json['other_user_name'] as String,
      netAmount: (json['net_amount'] as num).toDouble(),
      eventName: json['event_name'] as String,
      expenseDescription: json['expense_description'] as String,
    );
  }

  UserExpenseSummary toEntity() {
    return UserExpenseSummary(
      otherUserId: otherUserId,
      otherUserName: otherUserName,
      netAmount: netAmount,
      eventName: eventName,
      expenseDescription: expenseDescription,
    );
  }
}

class GroupExpenseSummaryModel {
  final double netAmount;

  GroupExpenseSummaryModel({required this.netAmount});

  factory GroupExpenseSummaryModel.fromJson(Map<String, dynamic> json) {
    return GroupExpenseSummaryModel(
      netAmount: (json['net_amount'] as num?)?.toDouble() ?? 0.0,
    );
  }

  GroupExpenseSummary toEntity() {
    return GroupExpenseSummary(netAmount: netAmount);
  }
}