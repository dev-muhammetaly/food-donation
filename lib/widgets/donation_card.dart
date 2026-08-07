import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/donation.dart';
import '../utils/app_theme.dart';
import 'status_badge.dart';

// Displays one donation and its available actions in the donation list.
class DonationCard extends StatelessWidget {
  const DonationCard({
    super.key,
    required this.donation,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkCollected,
  });
  //Contains all the information about the donation being displayed.

  final Donation donation;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkCollected;

  // Collected or expired donations cannot be marked as collected again.
  bool get _canMarkCollected {
    return donation.status != DonationStatus.collected &&
        donation.status != DonationStatus.expired;
  }

  @override
  Widget build(BuildContext context) {
    // The card places the image on the left and donation details on the right.
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Displays an asset image, phone image, or placeholder.
            _DonationThumbnail(imagePath: donation.imagePath),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          donation.foodName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      StatusBadge(status: donation.status),
                    ],
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '${donation.quantity} • '
                    '${donation.servings} servings',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Icon(
                        Icons.event_outlined,
                        size: 15,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Expires '
                          '${DateFormat('d MMM yyyy').format(donation.expiryDate)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Wrap moves buttons to a new line on narrow screens.
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _SmallActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        colour: AppTheme.darkGreen,
                        onPressed: onEdit,
                      ),
                      _SmallActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        colour: const Color(0xFFC83C3C),
                        onPressed: onDelete,
                      ),

                      // Hide the button for collected or expired donations.
                      if (_canMarkCollected)
                        _SmallActionButton(
                          icon: Icons.task_alt,
                          label: 'Mark Collected',
                          colour: AppTheme.warmOrange,
                          onPressed: onMarkCollected,
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Displays the donation image.
class _DonationThumbnail extends StatelessWidget {
  const _DonationThumbnail({this.imagePath});

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    final path = imagePath?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 92,
        height: 104,
        child: _buildImage(path),
      ),
    );
  }

  Widget _buildImage(String? path) {
    // Show placeholder when no image path has been provided.
    if (path == null || path.isEmpty) {
      return _buildPlaceholder();
    }

    // Display an image stored in assets/images.
    if (path.startsWith('assets/')) {
      return Image.asset(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Display an image selected on Android or web and stored as a data URL.
    if (path.startsWith('data:image/')) {
      try {
        final commaIndex = path.indexOf(',');
        final encodedImage = path.substring(commaIndex + 1);
        return Image.memory(
          base64Decode(encodedImage),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      } catch (_) {
        return _buildPlaceholder();
      }
    }

    // This also supports Firebase Storage URLs if cloud storage is added later.
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return Image.network(
        path,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    }

    // Show a placeholder for an unsupported value.
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppTheme.softGreen,
      alignment: Alignment.center,
      child: const Icon(
        Icons.restaurant,
        size: 38,
        color: AppTheme.mediumGreen,
      ),
    );
  }
}

// Reusable button used for Edit, Delete, and Mark Collected actions.
class _SmallActionButton extends StatelessWidget {
  const _SmallActionButton({
    required this.icon,
    required this.label,
    required this.colour,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final Color colour;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 16),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: colour,
        padding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 7,
        ),
        visualDensity: VisualDensity.compact,
        side: BorderSide(
          // withValues replaces the deprecated withOpacity method.
          color: colour.withValues(alpha: 0.55),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
