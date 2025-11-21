import 'package:equatable/equatable.dart';

class Achievement extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final DateTime? earnedAt;
  final bool isUnlocked;

  const Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    this.earnedAt,
    required this.isUnlocked,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    iconName,
    earnedAt,
    isUnlocked,
  ];
}
