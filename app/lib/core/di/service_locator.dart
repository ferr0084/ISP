import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../features/auth/data/datasources/auth_remote_data_source.dart';
import '../../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user.dart';
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/chats/data/repositories/chat_repository_impl.dart';
import '../../features/chats/domain/repositories/chat_repository.dart';
import '../../features/chats/domain/usecases/create_chat.dart';
import '../../features/chats/domain/usecases/get_chats.dart';
import '../../features/chats/domain/usecases/get_latest_messages.dart';
import '../../features/chats/domain/usecases/get_messages.dart';
import '../../features/chats/domain/usecases/get_recent_chats.dart';
import '../../features/chats/domain/usecases/send_message.dart';
import '../../features/chats/presentation/providers/chat_provider.dart';
import '../../features/chats/presentation/providers/message_provider.dart';
import '../../features/groups/data/datasources/group_members_remote_data_source.dart';
import '../../features/groups/data/datasources/group_members_remote_data_source_impl.dart';
import '../../features/groups/data/repositories/group_members_repository_impl.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/groups/data/repositories/invitation_repository_impl.dart';
import '../../features/groups/domain/repositories/group_members_repository.dart';
import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/events/data/datasources/events_remote_data_source.dart';
import '../../features/events/data/datasources/events_remote_data_source_impl.dart';
import '../../features/events/data/repositories/event_repository_impl.dart';
import '../../features/events/domain/repositories/event_repository.dart';
import '../../features/events/domain/usecases/get_events.dart';
import '../../features/events/domain/usecases/get_event.dart';
import '../../features/events/domain/usecases/create_event.dart';
import '../../features/events/domain/usecases/update_event.dart';
import '../../features/events/domain/usecases/delete_event.dart';
import '../../features/events/domain/usecases/get_event_invitations.dart';
import '../../features/events/domain/usecases/send_event_invitations.dart';
import '../../features/events/domain/usecases/respond_to_invitation.dart';
import '../../features/groups/domain/repositories/invitation_repository.dart';
import '../../features/groups/domain/usecases/get_group_members.dart';
import '../../features/groups/domain/usecases/search_users_not_in_group.dart';
import '../../features/groups/domain/usecases/send_group_invite.dart';
import '../../features/groups/presentation/notifiers/group_invite_notifier.dart';
import '../../features/groups/presentation/providers/group_detail_provider.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/home/presentation/providers/recent_chats_provider.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/domain/usecases/create_notification.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';
import '../../features/profile/data/datasources/profile_remote_data_source.dart';
import '../../features/profile/data/datasources/profile_remote_data_source_impl.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/profile/domain/usecases/upload_avatar.dart';
import '../../features/profile/domain/usecases/update_last_seen.dart';
import '../../features/idiot_game/data/datasources/idiot_game_remote_data_source.dart';
import '../../features/idiot_game/data/datasources/idiot_game_remote_data_source_impl.dart';
import '../../features/idiot_game/data/repositories/idiot_game_repository_impl.dart';
import '../../features/idiot_game/domain/repositories/idiot_game_repository.dart';
import '../../features/idiot_game/domain/usecases/create_game.dart';
import '../../features/idiot_game/domain/usecases/get_game_details.dart';
import '../../features/idiot_game/domain/usecases/get_game_history.dart';
import '../../features/idiot_game/domain/usecases/get_potential_players.dart';
import '../../features/idiot_game/domain/usecases/get_recent_games.dart';
import 'package:app/features/idiot_game/domain/usecases/get_user_achievements.dart';
import 'package:app/features/idiot_game/domain/usecases/get_user_stats.dart';
import 'package:app/features/idiot_game/domain/usecases/get_group_games.dart';
import '../../features/idiot_game/presentation/providers/idiot_game_provider.dart';
import '../../features/profile/presentation/providers/profile_provider.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../../features/events/presentation/providers/event_provider.dart';
import '../../features/contacts/data/repositories/contact_repository_impl.dart';
import '../../features/contacts/domain/repositories/contact_repository.dart';
import '../../features/contacts/presentation/notifiers/contact_list_notifier.dart';
import '../../features/home/data/repositories/friend_status_repository_impl.dart';
import '../../features/home/domain/repositories/friend_status_repository.dart';
import '../../features/home/domain/usecases/get_friend_statuses.dart';
import '../../features/home/presentation/providers/friend_status_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(supabaseClient: sl(), uuid: sl()),
  );
  sl.registerLazySingleton<GroupMembersRemoteDataSource>(
    () => GroupMembersRemoteDataSourceImpl(),
  );
  sl.registerLazySingleton<GroupMembersRepository>(
    () => GroupMembersRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRemoteDataSource>(
    () => NotificationRemoteDataSourceImpl(sl()),
  );
  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<IdiotGameRemoteDataSource>(
    () => IdiotGameRemoteDataSourceImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<IdiotGameRepository>(
    () => IdiotGameRepositoryImpl(remoteDataSource: sl()),
  );

  // Use Cases
  sl.registerLazySingleton<SignUp>(() => SignUp(sl()));
  sl.registerLazySingleton<LoginWithEmailAndPassword>(
    () => LoginWithEmailAndPassword(sl()),
  );
  sl.registerLazySingleton<Logout>(() => Logout(sl()));
  sl.registerLazySingleton<GetUser>(() => GetUser(sl()));
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()));
  sl.registerLazySingleton<GetProfile>(() => GetProfile(sl()));
  sl.registerLazySingleton<UploadAvatar>(() => UploadAvatar(sl()));
  sl.registerLazySingleton<UpdateLastSeen>(() => UpdateLastSeen(sl()));
  sl.registerLazySingleton<GetChats>(() => GetChats(sl()));
  sl.registerLazySingleton<CreateChat>(() => CreateChat(sl()));
  sl.registerLazySingleton<GetMessages>(() => GetMessages(sl()));
  sl.registerLazySingleton<SendMessage>(() => SendMessage(sl()));
  sl.registerLazySingleton<GetLatestMessages>(() => GetLatestMessages(sl()));
  sl.registerLazySingleton<GetRecentChats>(() => GetRecentChats(sl()));
  sl.registerLazySingleton<GetGroupMembers>(() => GetGroupMembers(sl()));
  sl.registerLazySingleton<SendGroupInvite>(() => SendGroupInvite(sl()));
  sl.registerLazySingleton<SearchUsersNotInGroup>(
    () => SearchUsersNotInGroup(sl()),
  );
  sl.registerLazySingleton<GetPotentialPlayers>(
    () => GetPotentialPlayers(sl()),
  );
  sl.registerLazySingleton<CreateGame>(() => CreateGame(sl()));
  sl.registerLazySingleton(() => GetRecentGames(sl()));
  sl.registerLazySingleton(() => GetGameHistory(sl()));
  sl.registerLazySingleton(() => GetGameDetails(sl()));
  sl.registerLazySingleton(() => GetUserStats(sl()));
  sl.registerLazySingleton(() => GetUserAchievements(sl()));
  sl.registerLazySingleton(() => GetGroupGames(sl()));
  // Events
  sl.registerLazySingleton<EventsRemoteDataSource>(
    () => EventsRemoteDataSourceImpl(client: sl<SupabaseClient>()),
  );
  sl.registerLazySingleton<EventRepository>(
    () => EventRepositoryImpl(remote: sl<EventsRemoteDataSource>()),
  );
  sl.registerLazySingleton(() => GetEvents(sl<EventRepository>()));
  sl.registerLazySingleton(() => GetEvent(sl<EventRepository>()));
  sl.registerLazySingleton(() => CreateEvent(sl<EventRepository>()));
  sl.registerLazySingleton(() => UpdateEvent(sl<EventRepository>()));
  sl.registerLazySingleton(() => DeleteEvent(sl<EventRepository>()));
  sl.registerLazySingleton(() => GetEventInvitations(sl<EventRepository>()));
  sl.registerLazySingleton(() => SendEventInvitations(sl<EventRepository>()));
  sl.registerLazySingleton(() => RespondToInvitation(sl<EventRepository>()));

  // Notifiers
  sl.registerFactory<UserProvider>(
    () => UserProvider(sl(), sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<ChatProvider>(() => ChatProvider(sl(), sl()));
  sl.registerFactory<GroupProvider>(() => GroupProvider(sl()));
  sl.registerFactoryParam<MessageProvider, String, void>(
    (chatId, _) => MessageProvider(sl(), sl(), chatId),
  );
  sl.registerFactoryParam<GroupDetailProvider, String, void>(
    (groupId, _) => GroupDetailProvider(sl(), sl(), sl(), groupId),
  );
  sl.registerFactory<GroupInviteNotifier>(
    () => GroupInviteNotifier(sl(), sl()),
  );
  sl.registerFactory<NotificationProvider>(() => NotificationProvider(sl()));
  sl.registerLazySingleton(() => CreateNotification(sl()));
  sl.registerFactory<RecentChatsProvider>(
    () => RecentChatsProvider(getRecentChats: sl()),
  );

  // Providers
  sl.registerFactory<IdiotGameProvider>(
    () => IdiotGameProvider(
      getPotentialPlayers: sl(),
      createGame: sl(),
      getRecentGames: sl(),
      getGameHistory: sl(),
      getGameDetails: sl(),
      getUserStats: sl(),
      getUserAchievements: sl(),
      getGroupGames: sl(),
    ),
  );

  sl.registerFactory<ProfileProvider>(
    () => ProfileProvider(uploadAvatar: sl(), userProvider: sl()),
  );
  sl.registerFactory(() => UserProfileProvider(getProfile: sl()));

  sl.registerFactory<EventProvider>(
    () => EventProvider(
      getEvents: sl(),
      getEvent: sl(),
      createEvent: sl(),
      updateEvent: sl(),
      deleteEvent: sl(),
      getEventInvitations: sl(),
      sendEventInvitations: sl(),
      respondToInvitation: sl(),
      createNotification: sl(),
      contactRepository: sl(),
      groupRepository: sl(),
    ),
  );

  // Contacts
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(supabaseClient: sl()),
  );
  sl.registerFactory<ContactListNotifier>(() => ContactListNotifier(sl()));

  // Friend Statuses
  sl.registerLazySingleton<FriendStatusRepository>(
    () => FriendStatusRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetFriendStatuses(sl()));
  sl.registerFactory<FriendStatusProvider>(() => FriendStatusProvider(sl()));

  // External
  sl.registerLazySingleton<Uuid>(() => const Uuid());
}
