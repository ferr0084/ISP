import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:app/core/error/failures.dart';
import '../../domain/entities/chat.dart';
import '../../domain/entities/chat_member.dart';
import '../../domain/entities/message.dart';
import '../../domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final SupabaseClient _supabaseClient;

  ChatRepositoryImpl(this._supabaseClient);

  @override
  Stream<Either<Failure, List<Chat>>> getChats() {
    final userId = _supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      return Stream.value(Right([])); // Return empty list if not authenticated
    }

    return _supabaseClient
        .from('chats')
        .stream(primaryKey: ['id'])
        .order('updated_at', ascending: false)
        .map((data) {
          try {
            final chats = data.map((json) => Chat(
              id: json['id'] as String,
              name: json['name'] as String?,
              createdAt: DateTime.parse(json['created_at'] as String),
              updatedAt: DateTime.parse(json['updated_at'] as String),
            )).toList();
            return Right(chats);
          } catch (e) {
            // Return empty list on parsing errors to avoid crashes
            return Right([]);
          }
        });
  }

  @override
  Future<Either<Failure, Chat>> getChat(String id) async {
    try {
      final response = await _supabaseClient
          .from('chats')
          .select()
          .eq('id', id)
          .single();

      final chat = Chat(
        id: response['id'] as String,
        name: response['name'] as String?,
        createdAt: DateTime.parse(response['created_at'] as String),
        updatedAt: DateTime.parse(response['updated_at'] as String),
      );
      return Right(chat);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Chat>> createChat(String? name, List<String> memberIds) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure()); // User must be authenticated to create chat
      }

      // Create chat
      final chatResponse = await _supabaseClient
          .from('chats')
          .insert({'name': name})
          .select()
          .single();

      final chatId = chatResponse['id'] as String;

      // Add members including creator
      final allMemberIds = {userId, ...memberIds};
      final memberInserts = allMemberIds.map((id) => {
        'chat_id': chatId,
        'user_id': id,
      }).toList();

      await _supabaseClient.from('chat_members').insert(memberInserts);

      final chat = Chat(
        id: chatId,
        name: name,
        createdAt: DateTime.parse(chatResponse['created_at'] as String),
        updatedAt: DateTime.parse(chatResponse['updated_at'] as String),
      );
      return Right(chat);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChat(Chat chat) async {
    try {
      await _supabaseClient
          .from('chats')
          .update({'name': chat.name})
          .eq('id', chat.id);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChat(String id) async {
    try {
      await _supabaseClient.from('chats').delete().eq('id', id);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Stream<Either<Failure, List<Message>>> getMessages(String chatId) {
    return _supabaseClient
        .from('messages')
        .stream(primaryKey: ['id'])
        .eq('chat_id', chatId)
        .order('created_at', ascending: false) // Most recent first for limiting
        .limit(100) // Limit to last 100 messages for performance
        .map((data) {
          try {
            final messages = data.map((json) => Message(
              id: json['id'] as String,
              chatId: json['chat_id'] as String,
              senderId: json['sender_id'] as String,
              content: json['content'] as String,
              createdAt: DateTime.parse(json['created_at'] as String),
              updatedAt: DateTime.parse(json['updated_at'] as String),
            )).toList()
              ..sort((a, b) => a.createdAt.compareTo(b.createdAt)); // Sort ascending for display
            return Right(messages);
          } catch (e) {
            return Left(ServerFailure());
          }
        });
  }

  @override
  Future<Either<Failure, Unit>> sendMessage(String chatId, String content) async {
    try {
      final userId = _supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        return Left(ServerFailure()); // User must be authenticated to send message
      }

      await _supabaseClient.from('messages').insert({
        'chat_id': chatId,
        'sender_id': userId,
        'content': content,
      });
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<ChatMember>>> getChatMembers(String chatId) async {
    try {
      final response = await _supabaseClient
          .from('chat_members')
          .select()
          .eq('chat_id', chatId);

      final members = response.map((json) => ChatMember(
        id: json['id'] as String,
        chatId: json['chat_id'] as String,
        userId: json['user_id'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
      )).toList();
      return Right(members);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> addChatMember(String chatId, String userId) async {
    try {
      await _supabaseClient.from('chat_members').insert({
        'chat_id': chatId,
        'user_id': userId,
      });
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> removeChatMember(String chatId, String userId) async {
    try {
      await _supabaseClient
          .from('chat_members')
          .delete()
          .eq('chat_id', chatId)
          .eq('user_id', userId);
      return Right(unit);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}