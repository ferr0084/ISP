import 'package:flutter/material.dart';

class LoginCallbackScreen extends StatelessWidget {
  const LoginCallbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Supabase deeplink callback
    // Supabase.instance.client.auth.getSessionFromUrl(
    //   Uri.base.toString(),
    // );

    // After the session is parsed, the user will be redirected to the home screen.
    // For now, show a loading indicator.
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
