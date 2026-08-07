import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/food_request.dart';
import '../utils/app_theme.dart';
import 'donation_image.dart';
import 'request_status_badge.dart';

class RequestCard extends StatelessWidget {
  const RequestCard({
    super.key,
    required this.request,
    required this.onViewPickupDetails,
    required this.onCancel,
  });

  final FoodRequest request;
  final VoidCallback onViewPickupDetails;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 64,
                height: 64,
                child: DonationImage(
                  imagePath: request.imagePath,
                  borderRadius: 10,
                  placeholderIconSize: 26,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            request.foodName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                        ),
                        RequestStatusBadge(status: request.status),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'From ${request.donorName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Requested ${DateFormat('d MMM yyyy').format(request.requestDate)} '
                      '• ${request.requestedQuantity}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (request.canViewPickupDetails)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onViewPickupDetails,
                    icon: const Icon(Icons.qr_code_2_outlined, size: 16),
                    label: const Text('View Pickup Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.darkGreen,
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
              if (request.canViewPickupDetails && request.canCancel)
                const SizedBox(width: 8),
              if (request.canCancel)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onCancel,
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Cancel Request'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF9A2727),
                      side: const BorderSide(color: Color(0xFFE9B7B7)),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
