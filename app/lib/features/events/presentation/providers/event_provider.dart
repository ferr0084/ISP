import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/service_locator.dart';
import '../../../contacts/domain/entities/contact.dart';
import '../../../contacts/domain/repositories/contact_repository.dart';
import '../../../groups/domain/repositories/group_repository.dart';
import '../../../notifications/domain/entities/notification.dart' as notif;
import '../../../notifications/domain/usecases/create_notification.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';
import '../../domain/usecases/create_event.dart';
import '../../domain/usecases/delete_event.dart';
import '../../domain/usecases/get_event.dart';
import '../../domain/usecases/get_event_invitations.dart';
import '../../domain/usecases/get_events.dart';
import '../../domain/usecases/get_my_invitations.dart';
import '../../domain/usecases/respond_to_invitation.dart';
import '../../domain/usecases/send_event_invitations.dart';
import '../../domain/usecases/update_event.dart';

class EventProvider extends ChangeNotifier {
  final GetEvents getEvents;
  final GetEvent getEvent;
  final CreateEvent createEvent;
  final UpdateEvent updateEvent;
  final DeleteEvent deleteEvent;
  final GetEventInvitations getEventInvitations;
  final SendEventInvitations sendEventInvitations;
  final RespondToInvitation respondToInvitation;
  final CreateNotification createNotification;
  final ContactRepository contactRepository;
  final GroupRepository groupRepository;
  final GetMyInvitations getMyInvitations;

  StreamSubscription? _eventsSubscription;
  StreamSubscription? _invitationsSubscription;
  List<Event> _allEvents = [];
  List<EventInvitation> _myInvitations = [];

  EventProvider({
    required this.getEvents,
    required this.getEvent,
    required this.createEvent,
    required this.updateEvent,
    required this.deleteEvent,
    required this.getEventInvitations,
    required this.sendEventInvitations,
    required this.respondToInvitation,
    required this.createNotification,
    required this.contactRepository,
    required this.groupRepository,
    required this.getMyInvitations,
  }) {
    _loadEvents();
  }

  List<Event> _events = [];
  List<Event> get events => _events;

  Event? _currentEvent;
  Event? get currentEvent => _currentEvent;

  List<EventInvitation> _currentEventInvitations = [];
  List<EventInvitation> get currentEventInvitations => _currentEventInvitations;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final Map<String, Contact> _contacts = {};
  final Map<String, String> _groupNames = {};

  String? getUserName(String userId) {
    final contact = _contacts[userId];
    if (contact == null) return null;
    return contact.nickname?.isNotEmpty == true
        ? contact.nickname
        : contact.name;
  }

  String? getGroupName(String groupId) => _groupNames[groupId];

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

  Future<void> fetchGroupName(String groupId) async {
    if (_groupNames.containsKey(groupId)) return;

    final result = await groupRepository.getGroup(groupId);
    result.fold(
      (failure) => null, // Ignore error
      (group) {
        _groupNames[groupId] = group.name;
        notifyListeners();
      },
    );
  }

  void _loadEvents() {
    _isLoading = true;
    notifyListeners();

    // Cancel existing subscriptions
    _eventsSubscription?.cancel();
    _invitationsSubscription?.cancel();

    // Listen to events
    _eventsSubscription = getEvents().listen(
      (either) {
        either.fold(
          (failure) {
            _error = failure.toString();
            _isLoading = false;
            notifyListeners();
          },
          (events) {
            _allEvents = events;
            _mergeEventsAndInvitations();
          },
        );
      },
    );

    // Listen to my invitations
    final currentUserId = sl<SupabaseClient>().auth.currentUser?.id;
    if (currentUserId != null) {
      _invitationsSubscription = getMyInvitations(currentUserId).listen(
        (either) {
          either.fold(
            (failure) {
              // Log error but don't block events
              debugPrint('Error fetching invitations: $failure');
            },
            (invitations) {
              _myInvitations = invitations;
              _mergeEventsAndInvitations();
            },
          );
        },
      );
    }
  }

  void _mergeEventsAndInvitations() {
    final currentUserId = sl<SupabaseClient>().auth.currentUser?.id;
    if (currentUserId == null) return;

    _events = _allEvents.map((event) {
      // Find my invitation for this event
      final myInvitation = _myInvitations
          .where((inv) => inv.eventId == event.id)
          .firstOrNull;

      // If I created the event, I don't necessarily have an invitation record in the DB
      // (depending on implementation), but the UI handles "Host" status separately.
      // However, if we want to attach the invitation to the event object:
      if (myInvitation != null) {
        // If the event already has invitations (from getEvents, though we know it doesn't),
        // we should merge or replace. Since getEvents doesn't return invitations,
        // we can just add this one to a list.
        return event.copyWith(invitations: [myInvitation]);
      }
      return event;
    }).toList();

    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _eventsSubscription?.cancel();
    _invitationsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadEventDetails(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final event = await getEvent(eventId);
      final invitations = await getEventInvitations(eventId);

      _currentEvent = event.copyWith(invitations: invitations);
      _currentEventInvitations = invitations;
      _error = null;

      // Fetch creator name
      fetchUserName(event.creatorId);

      // Fetch group name if applicable
      if (event.groupId != null) {
        fetchGroupName(event.groupId!);
      }

      // Fetch attendee names
      for (final invitation in invitations) {
        fetchUserName(invitation.inviteeId);
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createNewEvent({
    required String name,
    required String description,
    required DateTime date,
    required String location,
    required String creatorId,
    String? groupId,
    List<String> inviteeIds = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final event = Event(
        id: '', // Will be generated by Supabase
        name: name,
        description: description,
        date: date,
        location: location,
        creatorId: creatorId,
        groupId: groupId,
      );

      final createdEvent = await createEvent(event, inviteeIds: inviteeIds);

      // Notifications are now handled by the RPC or triggers, but if we want to keep
      // the manual notification logic for now, we can iterate and send them.
      // However, the RPC handles invitation creation.
      // The previous logic sent notifications separately.
      // Let's keep the notification logic but remove the invitation sending.

      if (inviteeIds.isNotEmpty) {
        // Create notifications for each invitee
        for (final inviteeId in inviteeIds) {
          final notification = notif.Notification(
            id: '', // Will be generated
            userId: inviteeId,
            type: 'event_invite',
            title: 'Event Invitation',
            message: 'You have been invited to "${event.name}"',
            data: {'event_id': createdEvent.id},
            read: false,
            createdAt: DateTime.now(),
          );
          await createNotification(notification);
        }
      }

      _error = null;
      _isLoading = false;
      _loadEvents(); // Refresh the list
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateExistingEvent(Event event) async {
    _isLoading = true;
    notifyListeners();

    try {
      await updateEvent(event);
      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExistingEvent(String eventId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await deleteEvent(eventId);

      // Manually remove from local state to ensure immediate UI update
      _allEvents.removeWhere((e) => e.id == eventId);
      _mergeEventsAndInvitations();

      _error = null;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendInvitations(String eventId, List<String> inviteeIds) async {
    _isLoading = true;
    notifyListeners();

    try {
      await sendEventInvitations(eventId, inviteeIds);

      // Get event details to create notifications
      final event = await getEvent(eventId);

      // Create notifications for each invitee
      for (final inviteeId in inviteeIds) {
        final notification = notif.Notification(
          id: '', // Will be generated
          userId: inviteeId,
          type: 'event_invite',
          title: 'Event Invitation',
          message: 'You have been invited to "${event.name}"',
          data: {'event_id': eventId},
          read: false,
          createdAt: DateTime.now(),
        );
        await createNotification(notification);
      }

      // Reload invitations
      await loadEventDetails(eventId);
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> respondToEventInvitation(
    String invitationId,
    InvitationStatus status, {
    DateTime? suggestedDate,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await respondToInvitation(
        invitationId,
        status,
        suggestedDate: suggestedDate,
      );
      // Reload current event details
      if (_currentEvent != null) {
        await loadEventDetails(_currentEvent!.id);
      }
      _error = null;
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentEvent() {
    _currentEvent = null;
    _currentEventInvitations = [];
    notifyListeners();
  }
}
