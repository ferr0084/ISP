import 'package:flutter/material.dart';
import 'package:app/features/profile/presentation/screens/profile_editing_screen.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ProfileEditingScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Center(
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 60,
                    backgroundImage: AssetImage(
                      'assets/images/avatar_s.png',
                    ), // Placeholder image
                  ),
                  const SizedBox(height: 16.0),
                  Text('John Doe', style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 8.0),
                  Text(
                    '@johndoe',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16.0),
                  const Text(
                    'UX Designer and coffee enthusiast.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16.0),
                  ),
                  const SizedBox(height: 32.0),
                  // Removed ElevatedButton since the functionality is moved to AppBar actions
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
