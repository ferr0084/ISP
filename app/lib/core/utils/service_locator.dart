import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_user.dart';
import '../../features/auth/domain/usecases/login_with_email_and_password.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/sign_up.dart';
import '../../features/auth/presentation/providers/user_provider.dart';

final sl = GetIt.instance;

void setupServiceLocator() {
  // Supabase
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Auth Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(sl<SupabaseClient>()),
  );

  // Auth Use Cases
  sl.registerLazySingleton(() => GetUser(sl<AuthRepository>()));
  sl.registerLazySingleton(
    () => LoginWithEmailAndPassword(sl<AuthRepository>()),
  );
  sl.registerLazySingleton(() => Logout(sl<AuthRepository>()));
  sl.registerLazySingleton(() => SignUp(sl<AuthRepository>()));

  // Auth Provider
  sl.registerLazySingleton(
    () => UserProvider(
      sl<SignUp>(),
      sl<LoginWithEmailAndPassword>(),
      sl<Logout>(),
    ),
  );
}
