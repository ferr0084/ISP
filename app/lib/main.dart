import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/router/app_router.dart';
import 'core/supabase/supabase_initializer.dart';
import 'core/utils/service_locator.dart';
import 'features/auth/presentation/providers/user_provider.dart';
import 'features/contacts/presentation/notifiers/contact_list_notifier.dart';
import 'features/groups/presentation/providers/group_provider.dart';
import 'features/contacts/presentation/notifiers/add_contact_notifier.dart';
import 'features/contacts/presentation/notifiers/contact_detail_notifier.dart'; // Added import // Added import
import 'core/theme/theme_data.dart'; // Import AppTheme
import 'core/theme/theme_provider.dart'; // Import ThemeProvider

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
          ), // Provide ThemeProvider
          ChangeNotifierProvider(create: (_) => sl<GroupProvider>()),
          ChangeNotifierProvider(create: (_) => sl<ContactListNotifier>()),
          ChangeNotifierProvider(create: (_) => sl<AddContactNotifier>()),
          ChangeNotifierProvider(create: (_) => sl<ContactDetailNotifier>()),
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
          theme: AppTheme.lightTheme, // Use light theme
          darkTheme: AppTheme.darkTheme, // Use dark theme
          themeMode: themeProvider.themeMode, // Control theme mode
          routerConfig: appRouter.router,
        );
      },
    );
  }
}
