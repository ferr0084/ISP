import 'dart:io';

import 'package:flutter/material.dart';

class GroupAvatar extends StatelessWidget {
  final String? avatarUrl;
  final double radius;
  final File? localImage;

  const GroupAvatar({
    super.key,
    this.avatarUrl,
    this.radius = 20,
    this.localImage,
  });

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;

    if (localImage != null) {
      imageProvider = FileImage(localImage!);
    } else if (avatarUrl != null && avatarUrl!.isNotEmpty) {
      if (avatarUrl!.startsWith('http')) {
        imageProvider = NetworkImage(avatarUrl!);
      } else {
        imageProvider = AssetImage(avatarUrl!);
      }
    }

    return CircleAvatar(
      radius: radius,
      backgroundImage: imageProvider,
      child: imageProvider == null
          ? Icon(
              Icons.group,
              size: radius,
            ) // Adjust icon size relative to radius
          : null,
    );
  }
}
