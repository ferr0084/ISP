import 'package:app/features/profile/domain/entities/user_profile.dart';
import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/group.dart';
import '../../domain/failures/group_failure.dart';
import '../../domain/repositories/group_repository.dart';

class GroupRepositoryImpl implements GroupRepository {
  final SupabaseClient _supabaseClient;

  GroupRepositoryImpl(this._supabaseClient);

  @override
  Stream<List<Group>> getGroupsStream() {
    return _supabaseClient.from('groups').stream(primaryKey: ['id']).map((
      events,
    ) {
      return events
          .map(
            (json) => Group(
              id: json['id'],
              name: json['name'],
              avatarUrl: json['avatar_url'],
              memberIds: List<String>.from(json['member_ids']),
              lastMessage: json['last_message'],
              time: DateTime.parse(json['time']),
              unreadCount: json['unread_count'],
              chatId: json['chat_id'],
            ),
          )
          .toList();
    });
  }

  @override
  Future<Either<GroupFailure, List<Group>>> getGroups() async {
    try {
      final response = await _supabaseClient.from('groups').select();
      final List<Group> groups = (response as List)
          .map(
            (json) => Group(
              id: json['id'],
              name: json['name'],
              avatarUrl: json['avatar_url'],
              memberIds: List<String>.from(json['member_ids']),
              lastMessage: json['last_message'],
              time: DateTime.parse(json['time']),
              unreadCount: json['unread_count'],
              chatId: json['chat_id'],
            ),
          )
          .toList();
      return Right(groups);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<GroupFailure, Group>> getGroup(String id) async {
    try {
      final response = await _supabaseClient
          .from('groups')
          .select()
          .eq('id', id)
          .single();
      final group = Group(
        id: response['id'],
        name: response['name'],
        avatarUrl: response['avatar_url'],
        memberIds: List<String>.from(response['member_ids']),
        lastMessage: response['last_message'],
        time: DateTime.parse(response['time']),
        unreadCount: response['unread_count'],
        chatId: response['chat_id'],
      );
      return Right(group);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return Left(GroupNotFoundFailure('Group with ID $id not found.'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> createGroup(Group group) async {
    try {
      final newId = const Uuid().v4(); // Generate UUID internally
      await _supabaseClient.from('groups').insert({
        'id': newId, // Use generated ID
        'name': group.name,
        'avatar_url': group.avatarUrl,
        'member_ids': group.memberIds,
        'last_message': group.lastMessage,
        'time': group.time.toIso8601String(),
        'unread_count': group.unreadCount,
      });
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> updateGroup(Group group) async {
    try {
      await _supabaseClient
          .from('groups')
          .update({
            'name': group.name,
            'avatar_url': group.avatarUrl,
            'member_ids': group.memberIds,
            'last_message': group.lastMessage,
            'time': group.time.toIso8601String(),
            'unread_count': group.unreadCount,
          })
          .eq('id', group.id);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<GroupFailure, Unit>> deleteGroup(String id) async {
    try {
      await _supabaseClient.from('groups').delete().eq('id', id);
      return const Right(unit);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<List<UserProfile>> searchUsersNotInGroup(
      String query, String groupId) async {
    final response = await _supabaseClient.rpc('search_users_not_in_group',
        params: {'p_group_id': groupId, 'p_search_term': query});

    if (response == null) {
      return [];
    }

    return (response as List)
        .map(
          (json) => UserProfile(
            id: json['id'],
            fullName: json['full_name'],
            avatarUrl: json['avatar_url'],
            email: json['email'],
          ),
        )
        .toList();
  }
}
