import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/donation.dart';
import '../utils/app_theme.dart';
import '../utils/donor_name.dart';
import 'donation_image.dart';
import 'status_badge.dart';

class BrowseDonationCard extends StatelessWidget {
  const BrowseDonationCard({
    super.key,
    required this.donation,
    required this.onTap,
  });

  final Donation donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppTheme.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 92,
                height: 104,
                child: DonationImage(
                  imagePath: donation.imagePath,
                  borderRadius: 12,
                ),
              ),
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
                      '${donation.category} • ${donation.quantity}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _IconLine(
                      icon: Icons.person_outline,
                      text: donorDisplayName(donation.donorId),
                    ),
                    const SizedBox(height: 4),
                    _IconLine(
                      icon: Icons.place_outlined,
                      text: donation.pickupAddress,
                    ),
                    const SizedBox(height: 4),
                    _IconLine(
                      icon: Icons.event_outlined,
                      text: 'Use by '
                          '${DateFormat('d MMM yyyy').format(donation.expiryDate)}',
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
