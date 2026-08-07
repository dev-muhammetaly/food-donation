import 'package:flutter/material.dart';

import '../models/donation.dart';
import '../services/donation_repository.dart';
import '../services/notification_repository.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/donation_card.dart';
import 'add_donation_screen.dart';
import 'edit_donation_screen.dart';
import 'notifications_screen.dart';

enum DonationFilter {
  all,
  active,
  requested,
  reserved,
  collected,
  expired,
}

extension DonationFilterText on DonationFilter {
  String get label {
    switch (this) {
      case DonationFilter.all:
        return 'All';
      case DonationFilter.active:
        return 'Active';
      case DonationFilter.requested:
        return 'Requested';
      case DonationFilter.reserved:
        return 'Reserved';
      case DonationFilter.collected:
        return 'Collected';
      case DonationFilter.expired:
        return 'Expired';
    }
  }
}

class MyDonationsScreen extends StatefulWidget {
  const MyDonationsScreen({
    super.key,
    required this.donationRepository,
    required this.notificationRepository,
    required this.requestRepository,
    required this.profileRepository,
    required this.currentDonorId,
  });

  final DonationRepository donationRepository;
  final NotificationRepository notificationRepository;
  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;
  final String currentDonorId;

  @override
  State<MyDonationsScreen> createState() => _MyDonationsScreenState();
}

class _MyDonationsScreenState extends State<MyDonationsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  DonationFilter _selectedFilter = DonationFilter.all;

  List<Donation> _applyFilter(List<Donation> donations) {
    switch (_selectedFilter) {
      case DonationFilter.all:
        return donations;
      case DonationFilter.active:
        return donations
            .where(
              (donation) => donation.status == DonationStatus.available,
            )
            .toList();
      case DonationFilter.requested:
        return donations
            .where(
              (donation) => donation.status == DonationStatus.requested,
            )
            .toList();
      case DonationFilter.reserved:
        return donations
            .where(
              (donation) => donation.status == DonationStatus.reserved,
            )
            .toList();
      case DonationFilter.collected:
        return donations
            .where(
              (donation) => donation.status == DonationStatus.collected,
            )
            .toList();
      case DonationFilter.expired:
        return donations
            .where(
              (donation) => donation.status == DonationStatus.expired,
            )
            .toList();
    }
  }

  Future<void> _openAddDonation() async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => AddDonationScreen(
          donationRepository: widget.donationRepository,
          currentDonorId: widget.currentDonorId,
        ),
      ),
    );
  }

  Future<void> _openEditDonation(Donation donation) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => EditDonationScreen(
          donation: donation,
          donationRepository: widget.donationRepository,
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.delete_outline,
            color: Color(0xFFC83C3C),
          ),
          title: const Text('Delete donation?'),
          content: Text(
            'Are you sure you want to delete "${donation.foodName}"? '
            'This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC83C3C),
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await widget.donationRepository.deleteDonation(donation.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${donation.foodName} was deleted.'),
      ),
    );
  }

  Future<void> _confirmCollected(Donation donation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.task_alt,
            color: AppTheme.mediumGreen,
          ),
          title: const Text('Mark as collected?'),
          content: Text(
            'Confirm that "${donation.foodName}" has been collected.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Confirm'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;
    await widget.donationRepository.markAsCollected(donation.id);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Donation marked as collected.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        donationRepository: widget.donationRepository,
        requestRepository: widget.requestRepository,
        notificationRepository: widget.notificationRepository,
        profileRepository: widget.profileRepository,
        currentUserId: widget.currentDonorId,
      ),
      appBar: AppBar(
        title: const Text('My Donations'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NotificationsScreen(
                  notificationRepository: widget.notificationRepository,
                ),
              ),
            ),
            icon: const Icon(Icons.notifications_none),
          ),
          IconButton(
            tooltip: 'Menu',
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
            icon: const Icon(Icons.menu),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.donationRepository,
        builder: (context, _) {
          final allDonations = widget.donationRepository.donationsFor(
            widget.currentDonorId,
          );
          final visibleDonations = _applyFilter(allDonations);

          return Column(
            children: [
              _FilterBar(
                selectedFilter: _selectedFilter,
                onSelected: (filter) {
                  setState(() => _selectedFilter = filter);
                },
              ),
              Expanded(
                child: visibleDonations.isEmpty
                    ? _EmptyDonations(
                        hasAnyDonation: allDonations.isNotEmpty,
                        onAddPressed: _openAddDonation,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                        itemCount: visibleDonations.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final donation = visibleDonations[index];
                          return DonationCard(
                            donation: donation,
                            onEdit: () => _openEditDonation(donation),
                            onDelete: () => _confirmDelete(donation),
                            onMarkCollected: () =>
                                _confirmCollected(donation),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddDonation,
        backgroundColor: AppTheme.warmOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Donation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.selectedFilter,
    required this.onSelected,
  });

  final DonationFilter selectedFilter;
  final ValueChanged<DonationFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(
          children: DonationFilter.values.map((filter) {
            final selected = filter == selectedFilter;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                selected: selected,
                showCheckmark: false,
                label: Text(filter.label),
                labelStyle: TextStyle(
                  color: selected ? Colors.white : AppTheme.textDark,
                  fontWeight: FontWeight.w700,
                ),
                selectedColor: AppTheme.mediumGreen,
                backgroundColor: const Color(0xFFF2F2EC),
                side: BorderSide.none,
                onSelected: (_) => onSelected(filter),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _EmptyDonations extends StatelessWidget {
  const _EmptyDonations({
    required this.hasAnyDonation,
    required this.onAddPressed,
  });

  final bool hasAnyDonation;
  final VoidCallback onAddPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 94,
              height: 94,
              decoration: const BoxDecoration(
                color: AppTheme.softGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism_outlined,
                size: 48,
                color: AppTheme.mediumGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              hasAnyDonation
                  ? 'No donations match this filter'
                  : 'You have not published a donation yet',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasAnyDonation
                  ? 'Choose another status to view your donations.'
                  : 'Share safe surplus food with someone in your community.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (!hasAnyDonation) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('Add First Donation'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
