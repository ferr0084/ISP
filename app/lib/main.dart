import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/theme/theme_data.dart';
import 'core/theme/theme_provider.dart';
import 'features/auth/presentation/providers/user_provider.dart';
import 'features/groups/presentation/notifiers/group_invite_notifier.dart';
import 'features/groups/presentation/providers/group_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseInitialized = await initSupabase();

  if (supabaseInitialized) {
    setupServiceLocator();
    runApp(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => sl<UserProvider>()),
          ChangeNotifierProvider(
            create: (_) => ThemeProvider(),
          ),
          ChangeNotifierProvider(create: (_) => sl<GroupProvider>()),
          ChangeNotifierProvider(create: (_) => sl<GroupInviteNotifier>()),
        ],
        child: const MyApp(),
      ),
    );
  } else {
    runApp(
      const MaterialApp(
        home: Scaffold(
          body: Center(child: Text('Failed to initialize Supabase')),
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final appRouter = AppRouter(userProvider);

    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp.router(
          title: 'ISP App',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeProvider.themeMode,
          routerConfig: appRouter.router,
        );
      },
    );
  }
}