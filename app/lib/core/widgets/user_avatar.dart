import 'dart:io';

import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String? avatarUrl;
  final String? name;
  final double radius;
  final String? defaultAssetImage;
  final File? localImage;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.avatarUrl,
    this.name,
    this.radius = 30,
    this.defaultAssetImage,
    this.localImage,
    this.backgroundColor,
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

    String? initials;
    if (name != null && name!.isNotEmpty) {
      initials = name!.substring(0, 1).toUpperCase();
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor,
      backgroundImage: imageProvider ?? (defaultAssetImage != null ? AssetImage(defaultAssetImage!) : null),
      child: imageProvider == null && defaultAssetImage == null
          ? Text(
              initials ?? '?',
              style: TextStyle(
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
                color: backgroundColor != null
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.onSurface,
              ),
            )
          : null,
    );
  }
}