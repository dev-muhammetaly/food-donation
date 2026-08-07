import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/food_request.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/donation_image.dart';
import '../widgets/request_status_badge.dart';

class PickupDetailsScreen extends StatelessWidget {
  const PickupDetailsScreen({
    super.key,
    required this.request,
    required this.requestRepository,
    required this.profileRepository,
  });

  final FoodRequest request;
  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;

  void _contactDonor(BuildContext context, FoodRequest current) {
    final donorProfile = profileRepository.profile;
    final hasContactDetails =
        donorProfile != null && donorProfile.id == current.donorId;

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(current.donorName),
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

  Future<void> _confirmCollection(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm collection?'),
        content: const Text(
          'Only confirm once you have physically collected this donation '
          'from the donor.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Not Yet'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Confirm Collection'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    await requestRepository.confirmCollection(request.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Collection confirmed. Enjoy!')),
      );
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: requestRepository,
      builder: (context, _) {
        // Re-read the latest copy in case the status changed underneath us.
        final current = requestRepository.requests.firstWhere(
          (r) => r.id == request.id,
          orElse: () => request,
        );

        final canConfirm = current.status == RequestStatus.readyForPickup;

        return Scaffold(
          appBar: AppBar(title: const Text('Pickup Details')),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 72,
                      height: 72,
                      child: DonationImage(
                        imagePath: current.imagePath,
                        borderRadius: 14,
                        placeholderIconSize: 30,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            current.foodName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textDark,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Donor: ${current.donorName}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    RequestStatusBadge(status: current.status),
                  ],
                ),
                const SizedBox(height: 20),
                _DetailCard(
                  rows: [
                    _DetailRow(
                      icon: Icons.place_outlined,
                      label: 'Pickup address',
                      value: current.pickupAddress,
                    ),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Pickup date & time',
                      value: DateFormat('d MMM yyyy • h:mm a')
                          .format(current.preferredPickupDateTime),
                    ),
                    _DetailRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Requested quantity',
                      value:
                          '${current.requestedQuantity} • ${current.peopleCount} '
                          'people',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => _contactDonor(context, current),
                  icon: const Icon(Icons.chat_bubble_outline, size: 16),
                  label: const Text('Contact Donor'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.darkGreen,
                  ),
                ),
                const SizedBox(height: 16),
                _MapPlaceholder(address: current.pickupAddress),
                const SizedBox(height: 16),
                _PickupCodeCard(code: current.pickupCode),
                const SizedBox(height: 16),
                const _SafetyNotice(),
              ],
            ),
          ),
          bottomNavigationBar: current.status == RequestStatus.completed
              ? null
              : SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                    child: SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: FilledButton.icon(
                        onPressed:
                            canConfirm ? () => _confirmCollection(context) : null,
                        icon: const Icon(Icons.check_circle_outline),
                        label: Text(
                          canConfirm
                              ? 'Confirm Collection'
                              : 'Waiting for donor to mark ready',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}

class _PickupCodeCard extends StatelessWidget {
  const _PickupCodeCard({required this.code});

  final String code;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.softGreen,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Column(
        children: [
          const Icon(
            Icons.qr_code_2,
            size: 56,
            color: AppTheme.darkGreen,
          ),
          const SizedBox(height: 8),
          const Text(
            'Show this code to the donor at pickup',
            style: TextStyle(fontSize: 12, color: AppTheme.textDark),
          ),
          const SizedBox(height: 4),
          Text(
            code,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: 2,
              color: AppTheme.darkGreen,
            ),
          ),
        ],
      ),
    );
  }
}

class _SafetyNotice extends StatelessWidget {
  const _SafetyNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFF6E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF0DDAE)),
      ),
      padding: const EdgeInsets.all(14),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: Color(0xFF95520A)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Please check food packaging and freshness on collection. '
              'Contact the donor immediately if anything looks unsafe to '
              'consume.',
              style: TextStyle(fontSize: 12, color: Color(0xFF6B4A10)),
            ),
          ),
        ],
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
  });

  final IconData icon;
  final String label;
  final String value;

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
          const Icon(
            Icons.location_on,
            color: AppTheme.mediumGreen,
            size: 30,
          ),
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
