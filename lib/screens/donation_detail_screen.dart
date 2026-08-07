import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/donation.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../utils/donor_name.dart';
import '../widgets/donation_image.dart';
import '../widgets/status_badge.dart';
import 'request_confirmation_screen.dart';

class DonationDetailScreen extends StatelessWidget {
  const DonationDetailScreen({
    super.key,
    required this.donation,
    required this.requestRepository,
    required this.profileRepository,
    required this.currentUserId,
  });

  final Donation donation;
  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;
  final String currentUserId;

  bool get _alreadyRequested =>
      requestRepository.hasActiveRequest(donation.id, currentUserId);

  bool get _canRequest =>
      donation.status == DonationStatus.available && !_alreadyRequested;

  void _contactDonor(BuildContext context) {
    final donorProfile = profileRepository.profile;
    final hasContactDetails =
        donorProfile != null && donorProfile.id == donation.donorId;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(donorDisplayName(donation.donorId)),
        content: hasContactDetails
            ? Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_outlined,
                        size: 18,
                        color: AppTheme.mediumGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(donorProfile.phone),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 18,
                        color: AppTheme.mediumGreen,
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(donorProfile.email)),
                    ],
                  ),
                ],
              )
            : const Text('This donor has not shared contact details yet.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _requestDonation(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RequestConfirmationScreen(
          donation: DonationSummary.fromDonation(
            donation,
            donorName: donorDisplayName(donation.donorId),
          ),
          requestRepository: requestRepository,
          currentUserId: currentUserId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donation Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: double.infinity,
              height: 220,
              child: DonationImage(
                imagePath: donation.imagePath,
                borderRadius: 16,
                placeholderIconSize: 64,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    donation.foodName,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textDark,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                StatusBadge(status: donation.status),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              donation.category,
              style: TextStyle(
                color: AppTheme.mediumGreen,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              donation.description,
              style: TextStyle(
                color: Colors.grey.shade800,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            _DetailCard(
              rows: [
                _DetailRow(
                  icon: Icons.inventory_2_outlined,
                  label: 'Quantity',
                  value:
                      '${donation.quantity} • '
                      '${donation.servings} servings',
                ),
                _DetailRow(
                  icon: Icons.person_outline,
                  label: 'Donor',
                  value: donorDisplayName(donation.donorId),
                  trailing: OutlinedButton.icon(
                    onPressed: () => _contactDonor(context),
                    icon: const Icon(Icons.chat_bubble_outline, size: 15),
                    label: const Text('Contact'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: AppTheme.darkGreen,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                _DetailRow(
                  icon: Icons.calendar_today_outlined,
                  label: 'Prepared on',
                  value: DateFormat(
                    'd MMM yyyy',
                  ).format(donation.preparationDate),
                ),
                _DetailRow(
                  icon: Icons.event_busy_outlined,
                  label: 'Expiry date',
                  value: DateFormat('d MMM yyyy').format(donation.expiryDate),
                ),
                _DetailRow(
                  icon: Icons.warning_amber_outlined,
                  label: 'Allergens / dietary info',
                  value: donation.allergyInformation.trim().isEmpty
                      ? 'Not specified'
                      : donation.allergyInformation,
                ),
                _DetailRow(
                  icon: Icons.place_outlined,
                  label: 'Pickup address',
                  value: donation.pickupAddress,
                ),
                _DetailRow(
                  icon: Icons.access_time,
                  label: 'Pickup time',
                  value: DateFormat(
                    'd MMM yyyy • h:mm a',
                  ).format(donation.pickupDateTime),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _MapPlaceholder(address: donation.pickupAddress),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              onPressed: _canRequest ? () => _requestDonation(context) : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.warmOrange,
                disabledBackgroundColor: Colors.grey.shade300,
              ),
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: Text(
                _canRequest
                    ? 'Request Donation'
                    : _alreadyRequested
                    ? 'Already Requested'
                    : 'Currently ${donation.status.label}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.rows});

  final List<_DetailRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i != 0) const Divider(height: 1, color: AppTheme.border),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppTheme.mediumGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _MapPlaceholder extends StatelessWidget {
  const _MapPlaceholder({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: AppTheme.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, color: AppTheme.mediumGreen, size: 30),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              address,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppTheme.darkGreen,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
