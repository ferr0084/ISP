import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user.dart'; // Added missing import
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/chats/data/repositories/chat_repository_impl.dart';
import '../../features/chats/domain/repositories/chat_repository.dart';
import '../../features/chats/domain/usecases/create_chat.dart';
import '../../features/chats/domain/usecases/get_chats.dart';
import '../../features/chats/domain/usecases/get_messages.dart';
import '../../features/chats/domain/usecases/send_message.dart';
import '../../features/chats/presentation/providers/chat_provider.dart';
import '../../features/chats/presentation/providers/message_provider.dart';
import '../../features/contacts/data/repositories/contact_repository_impl.dart';
import '../../features/contacts/data/repositories/invitation_repository.dart';
import '../../features/contacts/domain/repositories/contact_repository.dart';
import '../../features/contacts/presentation/notifiers/add_contact_notifier.dart';
import '../../features/contacts/presentation/notifiers/contact_detail_notifier.dart';
import '../../features/contacts/presentation/notifiers/contact_list_notifier.dart';
import '../../features/contacts/presentation/notifiers/invite_friends_notifier.dart';
import '../../features/contacts/presentation/notifiers/user_search_notifier.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart';
import '../../features/profile/domain/usecases/get_profile.dart';

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepository(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<ChatRepository>(() => ChatRepositoryImpl(sl()));
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<GroupRepository>(() => GroupRepositoryImpl(sl()));
  sl.registerLazySingleton<ProfileRepository>(
    () => ProfileRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton<SignUp>(() => SignUp(sl()));
  sl.registerLazySingleton<LoginWithEmailAndPassword>(
    () => LoginWithEmailAndPassword(sl()),
  );
  sl.registerLazySingleton<Logout>(() => Logout(sl()));
  sl.registerLazySingleton<GetUser>(
    () => GetUser(sl()),
  ); // Added GetUser registration
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()));
  sl.registerLazySingleton<GetProfile>(() => GetProfile(sl()));
  sl.registerLazySingleton<GetChats>(() => GetChats(sl()));
  sl.registerLazySingleton<CreateChat>(() => CreateChat(sl()));
  sl.registerLazySingleton<GetMessages>(() => GetMessages(sl()));
  sl.registerLazySingleton<SendMessage>(() => SendMessage(sl()));

  // Notifiers
  sl.registerFactory<UserProvider>(
    () => UserProvider(sl(), sl(), sl(), sl(), sl()),
  );
  sl.registerFactory<ChatProvider>(() => ChatProvider(sl(), sl()));
  sl.registerFactory<GroupProvider>(() => GroupProvider(sl()));
  sl.registerFactory<ContactListNotifier>(() => ContactListNotifier(sl()));
  sl.registerFactory<AddContactNotifier>(
    () => AddContactNotifier(contactRepository: sl()),
  );
  sl.registerFactory<ContactDetailNotifier>(() => ContactDetailNotifier(sl()));
  sl.registerFactory<InviteFriendsNotifier>(
    () => InviteFriendsNotifier(sl(), sl()),
  );
  sl.registerFactory<UserSearchNotifier>(
    () => UserSearchNotifier(sl()),
  sl.registerFactoryParam<MessageProvider, String, void>(
    (chatId, _) => MessageProvider(sl(), sl(), chatId),
  );
}
