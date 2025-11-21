import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../auth/presentation/providers/user_provider.dart';

class ProfileEditingScreen extends StatefulWidget {
  const ProfileEditingScreen({super.key});

  @override
  State<ProfileEditingScreen> createState() => _ProfileEditingScreenState();
}

class _ProfileEditingScreenState extends State<ProfileEditingScreen> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _nicknameController = TextEditingController();
  bool _emailNotifications = true;
  bool _pushNotifications = true;
  XFile? _selectedImage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _aboutController.dispose();
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<String?> _uploadImage(XFile image) async {
    final supabase = Supabase.instance.client;
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) return null;

    final fileName =
        '$userId/avatar-${DateTime.now().millisecondsSinceEpoch}.jpg';
    final file = File(image.path);

    try {
      await supabase.storage.from('avatars').upload(fileName, file);
      final publicUrl = supabase.storage.from('avatars').getPublicUrl(fileName);
      return publicUrl;
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final profile = userProvider.profile;

    // Initialize controllers if not set
    if (_fullNameController.text.isEmpty && profile != null) {
      _fullNameController.text = profile.fullName;
      _aboutController.text = profile.about ?? '';
      _nicknameController.text = profile.nickname ?? '';
      _emailNotifications = profile.notificationPreferences?['email'] ?? true;
      _pushNotifications = profile.notificationPreferences?['push'] ?? true;
    }

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
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _selectedImage != null
                        ? FileImage(File(_selectedImage!.path))
                        : profile?.avatarUrl != null
                        ? NetworkImage(profile!.avatarUrl!)
                        : const AssetImage('assets/images/avatar_s.png')
                              as ImageProvider,
                  ),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('Set New Photo'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            TextField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _nicknameController,
              decoration: const InputDecoration(
                labelText: 'Nickname',
                border: OutlineInputBorder(),
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
            const SizedBox(height: 24.0),
            const Text(
              'Notification Preferences',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            CheckboxListTile(
              title: const Text('Email Notifications'),
              value: _emailNotifications,
              onChanged: (value) {
                setState(() {
                  _emailNotifications = value ?? true;
                });
              },
            ),
            CheckboxListTile(
              title: const Text('Push Notifications'),
              value: _pushNotifications,
              onChanged: (value) {
                setState(() {
                  _pushNotifications = value ?? true;
                });
              },
            ),
            const SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () async {
                if (profile == null) return;

                String? avatarUrl = profile.avatarUrl;
                if (_selectedImage != null) {
                  avatarUrl = await _uploadImage(_selectedImage!);
                  if (avatarUrl == null) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to upload image')),
                      );
                    }
                    return;
                  }
                }

                final updatedProfile = profile.copyWith(
                  avatarUrl: avatarUrl,
                  fullName: _fullNameController.text,
                  about: _aboutController.text,
                  nickname: _nicknameController.text.isEmpty
                      ? null
                      : _nicknameController.text,
                  notificationPreferences: {
                    'email': _emailNotifications,
                    'push': _pushNotifications,
                  },
                );

                try {
                  await userProvider.updateUserProfile(updatedProfile);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully!'),
                    ),
                  );
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to update profile: $e')),
                  );
                }
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
