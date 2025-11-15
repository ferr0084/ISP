import 'package:flutter/material.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final TextEditingController _firstNameController = TextEditingController(
    text: 'John',
  );
  final TextEditingController _lastNameController = TextEditingController(
    text: 'Doe',
  );
  final TextEditingController _usernameController = TextEditingController(
    text: '@johndoe',
  );
  final TextEditingController _aboutController = TextEditingController(
    text: 'UX Designer and coffee enthusiast.',
  );

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _usernameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

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
        title: const Text('Edit Profile'),
        centerTitle: true,
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
                  TextButton(
                    onPressed: () {
                      // TODO: Implement change photo functionality
                    },
                    child: const Text('Set New Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'First name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16.0),
                Expanded(
                  child: TextField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'Last name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixText: '@',
                border: OutlineInputBorder(),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8.0, left: 8.0),
              child: Text(
                'This is how people can find you.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _aboutController,
              maxLines: 4,
              decoration: InputDecoration(
                labelText: 'About',
                border: const OutlineInputBorder(),
                counterText: '${_aboutController.text.length}/140',
              ),
              onChanged: (text) {
                setState(() {}); // To update the counter
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement save changes functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Save Changes button pressed!')),
                );
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18.0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
