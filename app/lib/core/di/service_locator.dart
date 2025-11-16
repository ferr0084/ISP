import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/contacts/data/repositories/invitation_repository.dart';
import '../../features/auth/presentation/providers/user_provider.dart';
import '../../features/groups/presentation/providers/group_provider.dart';
import '../../features/contacts/presentation/notifiers/contact_list_notifier.dart';
import '../../features/contacts/presentation/notifiers/add_contact_notifier.dart';
import '../../features/contacts/presentation/notifiers/contact_detail_notifier.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/update_profile.dart';
import '../../features/contacts/domain/repositories/contact_repository.dart';
import '../../features/contacts/data/repositories/contact_repository_impl.dart';
import '../../features/groups/domain/repositories/group_repository.dart';
import '../../features/groups/data/repositories/group_repository_impl.dart';
import '../../features/contacts/presentation/notifiers/invite_friends_notifier.dart';
import '../../features/auth/domain/usecases/get_user.dart'; // Added missing import

final GetIt sl = GetIt.instance;

Future<void> setupServiceLocator() async {
  // Supabase Client
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Repositories
  sl.registerLazySingleton<InvitationRepository>(
    () => InvitationRepository(sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ContactRepository>(
    () => ContactRepositoryImpl(supabaseClient: sl()),
  );
  sl.registerLazySingleton<GroupRepository>(
    () => GroupRepositoryImpl(sl()),
  );

  // Use Cases
  sl.registerLazySingleton<SignUp>(() => SignUp(sl()));
  sl.registerLazySingleton<LoginWithEmailAndPassword>(() => LoginWithEmailAndPassword(sl()));
  sl.registerLazySingleton<Logout>(() => Logout(sl()));
  sl.registerLazySingleton<GetUser>(() => GetUser(sl())); // Added GetUser registration
  sl.registerLazySingleton<UpdateProfile>(() => UpdateProfile(sl()));

  // Notifiers
  sl.registerFactory<UserProvider>(() => UserProvider(sl(), sl(), sl(), sl()));
  sl.registerFactory<GroupProvider>(() => GroupProvider(sl()));
  sl.registerFactory<ContactListNotifier>(() => ContactListNotifier(sl()));
  sl.registerFactory<AddContactNotifier>(() => AddContactNotifier(contactRepository: sl()));
  sl.registerFactory<ContactDetailNotifier>(() => ContactDetailNotifier(sl()));
  sl.registerFactory<InviteFriendsNotifier>(() => InviteFriendsNotifier(sl(), sl()));
}