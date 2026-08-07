import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.imagePath,
    this.radius = 48,
    this.onEditTap,
  });

  final String? imagePath;
  final double radius;

  // If provided, shows a small camera badge for changing the photo.
  final VoidCallback? onEditTap;

  // ProfileImageService stores photos as data URLs (works on native
  // platforms and Flutter Web); older asset/network paths are also
  // supported for consistency with DonationImage.
  ImageProvider? _resolveImage() {
    final path = imagePath?.trim();
    if (path == null || path.isEmpty) return null;

    if (path.startsWith('data:image/')) {
      try {
        final commaIndex = path.indexOf(',');
        final encodedImage = path.substring(commaIndex + 1);
        return MemoryImage(base64Decode(encodedImage));
      } catch (_) {
        return null;
      }
    }

    if (path.startsWith('assets/')) {
      return AssetImage(path);
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return NetworkImage(path);
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final image = _resolveImage();

    return Stack(
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: AppTheme.softGreen,
          backgroundImage: image,
          child: image != null
              ? null
              : Icon(
                  Icons.person,
                  size: radius,
                  color: AppTheme.darkGreen,
                ),
        ),
        if (onEditTap != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onEditTap,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppTheme.warmOrange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
