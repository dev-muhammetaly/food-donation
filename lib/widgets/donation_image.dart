import 'dart:convert';

import 'package:flutter/material.dart';

import '../utils/app_theme.dart';

class DonationImage extends StatelessWidget {
  const DonationImage({
    super.key,
    required this.imagePath,
    this.borderRadius = 0,
    this.placeholderIconSize = 38,
    this.fit = BoxFit.cover,
  });

  final String? imagePath;
  final double borderRadius;
  final double placeholderIconSize;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: _buildImage(imagePath?.trim()),
    );
  }

  Widget _buildImage(String? path) {
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    if (path.startsWith('data:image/')) {
      try {
        final commaIndex = path.indexOf(',');
        final encodedImage = path.substring(commaIndex + 1);
        return Image.memory(
          base64Decode(encodedImage),
          fit: fit,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: fit,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.softGreen,
      alignment: Alignment.center,
      child: Icon(
        Icons.restaurant,
        size: placeholderIconSize,
        color: AppTheme.mediumGreen,
      ),
    );
  }
}
