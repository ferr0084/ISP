import 'dart:io';

import 'package:app/features/auth/presentation/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/user_avatar.dart';
import '../providers/profile_provider.dart';

class ProfileViewScreen extends StatelessWidget {
  const ProfileViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        title: const Text('Profile'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              context.push('/profile/edit');
            },
          ),
        ],
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          final user = userProvider.user;
          final profile = userProvider.profile;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Center(
                  child: Column(
                    children: [
                      Consumer<ProfileProvider>(
                        builder: (context, provider, child) {
                          return Stack(
                            children: [
                               UserAvatar(
                                 avatarUrl: profile?.avatarUrl,
                                 name: profile?.fullName,
                                 radius: 60,
                                 defaultAssetImage: 'assets/images/avatar_s.png',
                               ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: IconButton(
                                  icon: const Icon(Icons.camera_alt),
                                  onPressed: () async {
                                    final imagePicker = ImagePicker();
                                    final pickedFile = await imagePicker
                                        .pickImage(source: ImageSource.gallery);
                                    if (pickedFile != null) {
                                      await provider.uploadProfilePicture(
                                        File(pickedFile.path),
                                      );
                                    }
                                  },
                                ),
                              ),
                              if (provider.isLoading)
                                const Positioned.fill(
                                  child: CircularProgressIndicator(),
                                ),
                            ],
                          );
                        },
                      ),
                      const SizedBox(height: 16.0),
                      Text(
                        profile?.fullName ?? 'N/A',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8.0),
                      if (profile?.nickname != null)
                        Text(
                          profile!.nickname!,
                          style: Theme.of(
                            context,
                          ).textTheme.titleSmall?.copyWith(color: Colors.blue),
                        ),
                      const SizedBox(height: 8.0),
                      Text(
                        user?.email ?? 'N/A',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(color: Colors.grey),
                      ),
                      const SizedBox(height: 16.0),
                      if (profile?.about != null)
                        Text(
                          profile!.about!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16.0),
                        )
                      else
                        const Text(
                          'No bio yet.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0, color: Colors.grey),
                        ),
                      const SizedBox(height: 16.0),
                      if (profile?.badges != null &&
                          profile!.badges!.isNotEmpty)
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: profile.badges!
                              .map(
                                (badge) => Chip(
                                  label: Text(badge),
                                  backgroundColor: Colors.amber,
                                ),
                              )
                              .toList(),
                        ),
                      const SizedBox(height: 32.0),
                      ElevatedButton(
                        onPressed: () {
                          context.push('/profile/stats');
                        },
                        child: const Text('View Personal Stats'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
