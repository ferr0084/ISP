import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/utils/service_locator.dart';
import 'features/auth/presentation/providers/user_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final supabaseInitialized = await initSupabase();

  if (supabaseInitialized) {
    setupServiceLocator();
    runApp(const MyApp());
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
    return ChangeNotifierProvider(
      create: (_) => sl<UserProvider>(),
      child: Builder(
        builder: (context) {
          final userProvider = Provider.of<UserProvider>(
            context,
            listen: false,
          );
          final appRouter = AppRouter(userProvider);

          return MaterialApp.router(
            title: 'ISP App',
            theme: ThemeData(primarySwatch: Colors.blue),
            routerConfig: appRouter.router,
          );
        },
      ),
    );
  }
}
