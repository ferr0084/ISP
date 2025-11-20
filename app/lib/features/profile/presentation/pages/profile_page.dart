import 'package:app/features/auth/presentation/providers/user_provider.dart';
import 'package:app/features/profile/domain/entities/profile.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditing = false;
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false).user;
    _nameController = TextEditingController(
      text: user?.userMetadata?['name'] ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            GoRouter.of(context).pop();
          },
        ),
        actions: [
           IconButton(
             icon: Icon(_isEditing ? Icons.check : Icons.edit),
             onPressed: () async {
               if (_isEditing) {
                 final updatedProfile = userProvider.profile?.copyWith(fullName: _nameController.text) ??
                     Profile(id: userProvider.user!.id, fullName: _nameController.text);
                 await userProvider.updateUserProfile(updatedProfile);
               }
               setState(() {
                 _isEditing = !_isEditing;
               });
             },
           ),
        ],
      ),
      body: user == null
          ? const Center(child: Text('No user logged in.'))
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      user.userMetadata?['avatar_url'] ?? '',
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _nameController,
                    enabled: _isEditing,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: user.email ?? '',
                    enabled: false,
                    decoration: const InputDecoration(labelText: 'Email'),
                  ),
                ],
              ),
            ),
    );
  }
}
