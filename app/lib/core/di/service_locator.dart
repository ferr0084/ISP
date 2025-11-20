import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user.dart';
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/profile/domain/usecases/update_profile.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/chats/data/repositories/chat_repository_impl.dart';
import '../../features/chats/domain/repositories/chat_repository.dart';
import '../../features/chats/domain/usecases/create_chat.dart';
import '../../features/chats/domain/usecases/get_chats.dart';
import '../../features/chats/domain/usecases/get_latest_messages.dart';
import '../../features/chats/domain/usecases/get_messages.dart';
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
import '../../features/groups/domain/repositories/invitation_repository.dart';
import '../../features/groups/domain/usecases/get_group_members.dart';
import '../../features/groups/domain/usecases/search_users_not_in_group.dart';
import '../../features/groups/domain/usecases/send_group_invite.dart';
import '../../features/groups/presentation/notifiers/group_invite_notifier.dart';
import '../../features/groups/presentation/providers/group_detail_provider.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';
import '../../features/notifications/data/datasources/notification_remote_data_source.dart';
import '../../features/notifications/data/repositories/notification_repository_impl.dart';
import '../../features/notifications/domain/repositories/notification_repository.dart';
import '../../features/notifications/presentation/providers/notification_provider.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
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

  // Use Cases
  sl.registerLazySingleton<SignUp>(() => SignUp(sl()));
  sl.registerLazySingleton<LoginWithEmailAndPassword>(
    () => LoginWithEmailAndPassword(sl()),
  );
  sl.registerLazySingleton<Logout>(() => Logout(sl()));
  sl.registerLazySingleton<GetUser>(() => GetUser(sl()));
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()));
  sl.registerLazySingleton<GetProfile>(() => GetProfile(sl()));
  sl.registerLazySingleton<GetChats>(() => GetChats(sl()));
  sl.registerLazySingleton<CreateChat>(() => CreateChat(sl()));
  sl.registerLazySingleton<GetMessages>(() => GetMessages(sl()));
  sl.registerLazySingleton<SendMessage>(() => SendMessage(sl()));
  sl.registerLazySingleton<GetLatestMessages>(() => GetLatestMessages(sl()));
  sl.registerLazySingleton<GetGroupMembers>(() => GetGroupMembers(sl()));
  sl.registerLazySingleton<SendGroupInvite>(() => SendGroupInvite(sl()));
  sl.registerLazySingleton<SearchUsersNotInGroup>(
    () => SearchUsersNotInGroup(sl()),
  );

  // Notifiers
  sl.registerFactory<UserProvider>(
    () => UserProvider(sl(), sl(), sl(), sl(), sl()),
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
}
