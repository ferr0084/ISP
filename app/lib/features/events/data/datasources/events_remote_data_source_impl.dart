import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/event.dart';
import '../../domain/entities/event_invitation.dart';
import 'events_remote_data_source.dart';

class EventsRemoteDataSourceImpl implements EventsRemoteDataSource {
  final SupabaseClient _client;
  EventsRemoteDataSourceImpl({required SupabaseClient client})
    : _client = client;

  @override
  Stream<List<Event>> getEvents() {
    return _client
        .from('events')
        .stream(primaryKey: ['id'])
        .order('date')
        .map((list) => list.map((e) => Event.fromJson(e)).toList());
  }

  @override
  Future<Event> getEvent(String id) async {
    final res = await _client.from('events').select().eq('id', id).single();
    return Event.fromJson(res);
  }

  @override
  Future<Event> createEvent(
    Event event, {
    List<String> inviteeIds = const [],
  }) async {
    final params = {
      'p_name': event.name,
      'p_description': event.description,
      'p_date': event.date.toIso8601String(),
      'p_location': event.location,
      'p_creator_id': event.creatorId,
      'p_group_id': event.groupId,
      'p_invitee_ids': inviteeIds,
    };

    final res = await _client.rpc(
      'create_event_with_invitations',
      params: params,
    );
    return Event.fromJson(res);
  }

  @override
  Future<void> updateEvent(Event event) async {
    await _client.from('events').update(event.toJson()).eq('id', event.id);
  }

  @override
  Future<void> deleteEvent(String id) async {
    await _client.from('events').delete().eq('id', id);
  }

  @override
  Future<List<EventInvitation>> getEventInvitations(String eventId) async {
    final response = await _client
        .from('event_invitations')
        .select()
        .eq('event_id', eventId);

    return (response as List<dynamic>)
        .map((json) => EventInvitation.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<void> sendEventInvitations(
    String eventId,
    List<String> inviteeIds,
  ) async {
    final inviterId = _client.auth.currentUser!.id;
    final invitations = inviteeIds
        .map(
          (inviteeId) => {
            'event_id': eventId,
            'invitee_id': inviteeId,
            'inviter_id': inviterId,
            'status': 'pending',
          },
        )
        .toList();

    await _client.from('event_invitations').insert(invitations);
  }

  @override
  Future<void> respondToInvitation(
    String invitationId,
    InvitationStatus status, {
    DateTime? suggestedDate,
  }) async {
    final updateData = {
      'status': status.name,
      if (suggestedDate != null)
        'suggested_date': suggestedDate.toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };

    await _client
        .from('event_invitations')
        .update(updateData)
        .eq('id', invitationId);
  }

  @override
  Stream<List<EventInvitation>> getMyInvitations(String userId) {
    return _client
        .from('event_invitations')
        .stream(primaryKey: ['id'])
        .eq('invitee_id', userId)
        .map(
          (list) => list.map((json) => EventInvitation.fromJson(json)).toList(),
        );
  }
}
