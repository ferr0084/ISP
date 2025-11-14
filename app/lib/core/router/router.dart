import 'package:app/features/auth/presentation/screens/login_or_create_account_screen.dart';
import 'package:app/features/auth/presentation/screens/welcome_screen.dart';
import 'package:app/features/home/presentation/screens/home_screen.dart';
import 'package:go_router/go_router.dart';

final router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const WelcomeScreen()),
    GoRoute(
      path: '/login-or-create-account',
      builder: (context, state) => const LoginOrCreateAccountScreen(),
    ),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
  ],
);
