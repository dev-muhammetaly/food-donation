import 'package:flutter/material.dart';

import '../models/donation.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/donation_image.dart';
import 'request_confirmation_screen.dart';

/// Stands in for Member 2's "Available Donations" page so this module can
/// demonstrate and be tested end-to-end on its own. In the merged app,
/// `DonationDetailScreen`'s "Request Donation" button pushes
/// `RequestConfirmationScreen` directly instead of going through this
/// screen.
class BrowseDonationsDemoScreen extends StatelessWidget {
  const BrowseDonationsDemoScreen({
    super.key,
    required this.donations,
    required this.requestRepository,
    required this.currentUserId,
  });

  final List<Donation> donations;
  final RequestRepository requestRepository;
  final String currentUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Donations (Demo)')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: donations.length,
        itemBuilder: (context, index) {
          final donation = donations[index];
          final alreadyRequested = requestRepository.hasActiveRequest(
            donation.id,
            currentUserId,
          );

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                SizedBox(
                  width: 56,
                  height: 56,
                  child: DonationImage(
                    imagePath: donation.imagePath,
                    borderRadius: 10,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        donation.foodName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${donation.category} • ${donation.quantity}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                FilledButton(
                  onPressed: donation.isAvailable && !alreadyRequested
                      ? () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => RequestConfirmationScreen(
                              donation: DonationSummary.fromDonation(donation),
                              requestRepository: requestRepository,
                              currentUserId: currentUserId,
                            ),
                          ),
                        )
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.warmOrange,
                    disabledBackgroundColor: Colors.grey.shade300,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    alreadyRequested
                        ? 'Requested'
                        : donation.isAvailable
                        ? 'Request'
                        : 'Unavailable',
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
