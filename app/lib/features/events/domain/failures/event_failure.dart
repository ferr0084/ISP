import 'package:equatable/equatable.dart';

abstract class EventFailure extends Equatable {
  const EventFailure();

  String get message;

  @override
  List<Object?> get props => [];
}

class InvalidEventDateFailure extends EventFailure {
  final String _message;

  const InvalidEventDateFailure([String message = 'Event date cannot be in the past']) : _message = message;

  @override
  String get message => _message;

  @override
  List<Object?> get props => [_message];
}

class TooManyInviteesFailure extends EventFailure {
  final int maxInvitees;
  final String _message;

  const TooManyInviteesFailure(this.maxInvitees, [String message = 'Too many invitees selected']) : _message = message;

  @override
  String get message => _message.replaceAll('{max}', maxInvitees.toString());

  @override
  List<Object?> get props => [maxInvitees, _message];
}

class EventValidationFailure extends EventFailure {
  final String _message;

  const EventValidationFailure(this._message);

  @override
  String get message => _message;

  @override
  List<Object?> get props => [_message];
}