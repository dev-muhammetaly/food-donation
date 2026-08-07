import 'package:flutter/material.dart';

import '../models/donation.dart';
import '../services/donation_repository.dart';
import '../services/notification_repository.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/browse_donation_card.dart';
import 'add_donation_screen.dart';
import 'donation_detail_screen.dart';
import 'my_donations_screen.dart';
import 'notifications_screen.dart';

enum ExpiryFilter { any, today, thisWeek, thisMonth }

extension ExpiryFilterText on ExpiryFilter {
  String get label {
    switch (this) {
      case ExpiryFilter.any:
        return 'Any use-by date';
      case ExpiryFilter.today:
        return 'Use by today';
      case ExpiryFilter.thisWeek:
        return 'Use by this week';
      case ExpiryFilter.thisMonth:
        return 'Use by this month';
    }
  }
}

const _allCategories = 'All categories';
const _allLocations = 'All locations';

class DonationListScreen extends StatefulWidget {
  const DonationListScreen({
    super.key,
    required this.donationRepository,
    required this.requestRepository,
    required this.notificationRepository,
    required this.profileRepository,
    required this.currentDonorId,
  });

  final DonationRepository donationRepository;
  final RequestRepository requestRepository;
  final NotificationRepository notificationRepository;
  final ProfileRepository profileRepository;
  final String currentDonorId;

  @override
  State<DonationListScreen> createState() => _DonationListScreenState();
}

class _DonationListScreenState extends State<DonationListScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedCategory = _allCategories;
  String _selectedLocation = _allLocations;
  ExpiryFilter _selectedExpiry = ExpiryFilter.any;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _matchesExpiry(Donation donation) {
    if (_selectedExpiry == ExpiryFilter.any) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expiryDay = DateTime(
      donation.expiryDate.year,
      donation.expiryDate.month,
      donation.expiryDate.day,
    );
    final daysUntilExpiry = expiryDay.difference(today).inDays;

    switch (_selectedExpiry) {
      case ExpiryFilter.any:
        return true;
      case ExpiryFilter.today:
        return daysUntilExpiry == 0;
      case ExpiryFilter.thisWeek:
        return daysUntilExpiry >= 0 && daysUntilExpiry <= 7;
      case ExpiryFilter.thisMonth:
        return daysUntilExpiry >= 0 && daysUntilExpiry <= 30;
    }
  }

  List<Donation> _applyFilters(List<Donation> donations) {
    final query = _searchQuery.trim().toLowerCase();

    return donations.where((donation) {
      final matchesQuery = query.isEmpty ||
          donation.foodName.toLowerCase().contains(query) ||
          donation.category.toLowerCase().contains(query);

      final matchesCategory = _selectedCategory == _allCategories ||
          donation.category == _selectedCategory;

      final matchesLocation = _selectedLocation == _allLocations ||
          donation.pickupAddress == _selectedLocation;

      return matchesQuery &&
          matchesCategory &&
          matchesLocation &&
          _matchesExpiry(donation);
    }).toList();
  }

  void _clearFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedCategory = _allCategories;
      _selectedLocation = _allLocations;
      _selectedExpiry = ExpiryFilter.any;
    });
  }

  void _openDetails(Donation donation) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DonationDetailScreen(
          donation: donation,
          requestRepository: widget.requestRepository,
          profileRepository: widget.profileRepository,
          currentUserId: widget.currentDonorId,
        ),
      ),
    );
  }

  void _openAddDonation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddDonationScreen(
          donationRepository: widget.donationRepository,
          currentDonorId: widget.currentDonorId,
        ),
      ),
    );
  }

  void _openMyDonations() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MyDonationsScreen(
          donationRepository: widget.donationRepository,
          notificationRepository: widget.notificationRepository,
          requestRepository: widget.requestRepository,
          profileRepository: widget.profileRepository,
          currentDonorId: widget.currentDonorId,
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationsScreen(
          notificationRepository: widget.notificationRepository,
        ),
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
        leading: IconButton(
          tooltip: 'Menu',
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          icon: const Icon(Icons.menu),
        ),
        title: const Text('CommunityCare FoodShare'),
        actions: [
          IconButton(
            tooltip: 'My Donations',
            onPressed: _openMyDonations,
            icon: const Icon(Icons.inventory_2_outlined),
          ),
          IconButton(
            tooltip: 'Notifications',
            onPressed: _openNotifications,
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
      body: AnimatedBuilder(
        animation: widget.donationRepository,
        builder: (context, _) {
          final allAvailable = widget.donationRepository.availableDonations;
          final visibleDonations = _applyFilters(allAvailable);

          final categories = <String>{
            _allCategories,
            ...allAvailable.map((donation) => donation.category),
          }.toList();
          final locations = <String>{
            _allLocations,
            ...allAvailable.map((donation) => donation.pickupAddress),
          }.toList();

          final filtersActive = _searchQuery.isNotEmpty ||
              _selectedCategory != _allCategories ||
              _selectedLocation != _allLocations ||
              _selectedExpiry != ExpiryFilter.any;

          return Column(
            children: [
              _SearchAndFilters(
                controller: _searchController,
                onSearchChanged: (value) {
                  setState(() => _searchQuery = value);
                },
                selectedCategory: _selectedCategory,
                categories: categories,
                onCategorySelected: (value) {
                  setState(() => _selectedCategory = value);
                },
                selectedLocation: _selectedLocation,
                locations: locations,
                onLocationSelected: (value) {
                  setState(() => _selectedLocation = value);
                },
                selectedExpiry: _selectedExpiry,
                onExpirySelected: (value) {
                  setState(() => _selectedExpiry = value);
                },
              ),
              Expanded(
                child: visibleDonations.isEmpty
                    ? _EmptyResults(
                        hasAnyDonation: allAvailable.isNotEmpty,
                        filtersActive: filtersActive,
                        onClearFilters: _clearFilters,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                        itemCount: visibleDonations.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final donation = visibleDonations[index];
                          return BrowseDonationCard(
                            donation: donation,
                            onTap: () => _openDetails(donation),
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

class _SearchAndFilters extends StatelessWidget {
  const _SearchAndFilters({
    required this.controller,
    required this.onSearchChanged,
    required this.selectedCategory,
    required this.categories,
    required this.onCategorySelected,
    required this.selectedLocation,
    required this.locations,
    required this.onLocationSelected,
    required this.selectedExpiry,
    required this.onExpirySelected,
  });

  final TextEditingController controller;
  final ValueChanged<String> onSearchChanged;
  final String selectedCategory;
  final List<String> categories;
  final ValueChanged<String> onCategorySelected;
  final String selectedLocation;
  final List<String> locations;
  final ValueChanged<String> onLocationSelected;
  final ExpiryFilter selectedExpiry;
  final ValueChanged<ExpiryFilter> onExpirySelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        children: [
          TextField(
            controller: controller,
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search donations...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        controller.clear();
                        onSearchChanged('');
                      },
                    ),
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip<String>(
                  icon: Icons.restaurant_menu,
                  label: selectedCategory,
                  isActive: selectedCategory != _allCategories,
                  items: categories,
                  itemLabel: (value) => value,
                  onSelected: onCategorySelected,
                ),
                const SizedBox(width: 8),
                _FilterChip<String>(
                  icon: Icons.place_outlined,
                  label: selectedLocation == _allLocations
                      ? 'Location'
                      : selectedLocation,
                  isActive: selectedLocation != _allLocations,
                  items: locations,
                  itemLabel: (value) => value,
                  onSelected: onLocationSelected,
                ),
                const SizedBox(width: 8),
                _FilterChip<ExpiryFilter>(
                  icon: Icons.event_outlined,
                  label: selectedExpiry.label,
                  isActive: selectedExpiry != ExpiryFilter.any,
                  items: ExpiryFilter.values,
                  itemLabel: (value) => value.label,
                  onSelected: onExpirySelected,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip<T> extends StatelessWidget {
  const _FilterChip({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.items,
    required this.itemLabel,
    required this.onSelected,
  });

  final IconData icon;
  final String label;
  final bool isActive;
  final List<T> items;
  final String Function(T value) itemLabel;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (context) => items
          .map(
            (item) => PopupMenuItem<T>(
              value: item,
              child: Text(itemLabel(item)),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.softGreen : const Color(0xFFF2F2EC),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppTheme.mediumGreen : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: AppTheme.darkGreen),
            const SizedBox(width: 6),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
            ),
            const Icon(Icons.arrow_drop_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class _EmptyResults extends StatelessWidget {
  const _EmptyResults({
    required this.hasAnyDonation,
    required this.filtersActive,
    required this.onClearFilters,
  });

  final bool hasAnyDonation;
  final bool filtersActive;
  final VoidCallback onClearFilters;

  @override
  Widget build(BuildContext context) {
    final showClearFilters = hasAnyDonation && filtersActive;

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
                Icons.search_off,
                size: 48,
                color: AppTheme.mediumGreen,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              showClearFilters
                  ? 'No donations match your search'
                  : 'No donations are available right now',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              showClearFilters
                  ? 'Try a different search term or clear your filters.'
                  : 'Check back soon, or encourage a donor to publish food.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            if (showClearFilters) ...[
              const SizedBox(height: 20),
              FilledButton.icon(
                onPressed: onClearFilters,
                icon: const Icon(Icons.filter_alt_off),
                label: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
