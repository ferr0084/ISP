import 'dart:io';

import 'package:flutter/material.dart';
import 'package:app/features/auth/presentation/providers/user_provider.dart';

import '../../domain/usecases/upload_avatar.dart';

class ProfileProvider extends ChangeNotifier {
  final UploadAvatar uploadAvatar;
  final UserProvider userProvider;

  ProfileProvider({required this.uploadAvatar, required this.userProvider});

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> uploadProfilePicture(File file) async {
    _isLoading = true;
    notifyListeners();

    final result = await uploadAvatar(UploadAvatarParams(file: file));

    result.fold(
      (failure) {
        // TODO: Handle failure
      },
      (avatarUrl) {
        final updatedProfile =
            userProvider.profile!.copyWith(avatarUrl: avatarUrl);
        userProvider.updateUserProfile(updatedProfile);
      },
    );

    _isLoading = false;
    notifyListeners();
  }
}
