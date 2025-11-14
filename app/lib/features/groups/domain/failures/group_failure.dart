import 'package:equatable/equatable.dart';

abstract class GroupFailure extends Equatable {
  final String message;

  const GroupFailure(this.message);

  @override
  List<Object> get props => [message];
}

class ServerFailure extends GroupFailure {
  const ServerFailure(super.message);
}

class CacheFailure extends GroupFailure {
  const CacheFailure(super.message);
}

class GroupNotFoundFailure extends GroupFailure {
  const GroupNotFoundFailure(super.message);
}

class UnknownGroupFailure extends GroupFailure {
  const UnknownGroupFailure(super.message);
}
