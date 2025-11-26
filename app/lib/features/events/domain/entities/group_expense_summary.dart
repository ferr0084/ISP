import 'package:equatable/equatable.dart';

class GroupExpenseSummary extends Equatable {
  final double netAmount;

  const GroupExpenseSummary({
    required this.netAmount,
  });

  @override
  List<Object?> get props => [netAmount];
}