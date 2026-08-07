import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/donation.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../services/donation_repository.dart';
import '../services/notification_repository.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_colors.dart';
import '../utils/app_routes.dart';
import '../widgets/donation_image.dart';
import 'donation_detail_screen.dart';
import 'donation_list_screen.dart';
import 'add_donation_screen.dart';
import 'my_requests_screen.dart';
import 'notifications_screen.dart';
import 'profile_screen.dart';

/// Main overview and navigation hub.
class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.donationRepository,
    required this.requestRepository,
    required this.profileRepository,
    required this.notificationRepository,
    required this.currentDonorId,
  });

  final DonationRepository donationRepository;
  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;
  final NotificationRepository notificationRepository;
  final String currentDonorId;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _tab = 0;
  String _query = '';
  String _category = 'All';

  // Matches the categories donors actually choose from in DonationForm, so
  // filtering here can match real donations.
  static const _categories = [
    'All',
    'Cooked Food',
    'Fresh Produce',
    'Groceries',
    'Bakery',
    'Dairy',
    'Drinks',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncProfile());
  }

  // Keeps the Profile tab's details in sync with whoever is actually signed
  // in, instead of always showing the seeded demo profile.
  Future<void> _syncProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final existing = widget.profileRepository.profile;
    if (existing != null && existing.id == user.id) return;

    await widget.profileRepository.updateProfile(
      UserProfile(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        phone: user.phone,
        accountType: user.accountType,
        address: user.address,
        donationsCount: existing?.id == user.id ? existing!.donationsCount : 0,
        requestsCount: existing?.id == user.id ? existing!.requestsCount : 0,
        mealsImpact: existing?.id == user.id ? existing!.mealsImpact : 0,
        profileImagePath:
            existing?.id == user.id ? existing!.profileImagePath : null,
      ),
    );
  }

  List<Donation> get _visible {
    final available = widget.donationRepository.availableDonations;

    return available.where((d) {
      final matchesCategory = _category == 'All' || d.category == _category;
      final matchesQuery = _query.isEmpty ||
          d.foodName.toLowerCase().contains(_query.toLowerCase()) ||
          d.category.toLowerCase().contains(_query.toLowerCase());
      return matchesCategory && matchesQuery;
    }).toList();
  }

  void _openDonationDetails(Donation donation) {
    Navigator.of(context).push(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _buildBody(context),
      bottomNavigationBar: _BottomBar(
        current: _tab,
        onSelect: (i) => setState(() => _tab = i),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    switch (_tab) {
      case 0:
        return _buildHome(context);
      case 1:
        return DonationListScreen(
          donationRepository: widget.donationRepository,
          requestRepository: widget.requestRepository,
          notificationRepository: widget.notificationRepository,
          profileRepository: widget.profileRepository,
          currentDonorId: widget.currentDonorId,
        );
      case 2:
        return MyRequestsScreen(
          requestRepository: widget.requestRepository,
          profileRepository: widget.profileRepository,
          currentUserId: widget.currentDonorId,
        );
      case 3:
        return NotificationsScreen(
          notificationRepository: widget.notificationRepository,
        );
      case 4:
        return ProfileScreen(
          profileRepository: widget.profileRepository,
          onLogout: () async {
            await context.read<AuthProvider>().logout();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (_) => false,
            );
          },
        );
      default:
        return _buildHome(context);
    }
  }

  void _openDonate(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddDonationScreen(
          donationRepository: widget.donationRepository,
          currentDonorId: widget.currentDonorId,
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    final user = context.watch<AuthProvider>().user;

    // Listens for donation changes so a newly published donation (or one
    // that gets requested/collected elsewhere) shows up here without the
    // user having to leave and re-enter the Home tab.
    return AnimatedBuilder(
      animation: widget.donationRepository,
      builder: (context, _) => _buildHomeContent(context, user),
    );
  }

  Widget _buildHomeContent(BuildContext context, UserModel? user) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            _GreetingHeader(
              name: user?.firstName ?? 'there',
              notificationRepository: widget.notificationRepository,
            ),
            Transform.translate(
              offset: const Offset(0, 72),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: _ImpactCard(mealsShared: '1,248', familiesHelped: '320'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 88),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: TextField(
            onChanged: (v) => setState(() => _query = v),
            decoration: InputDecoration(
              hintText: 'Search food or items...',
              prefixIcon: const Padding(
                padding: EdgeInsets.only(left: 8, right: 4),
                child: Icon(Icons.search, color: AppColors.textSecondary),
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 16),
              border: _pillBorder(AppColors.border),
              enabledBorder: _pillBorder(AppColors.border),
              focusedBorder: _pillBorder(AppColors.primary, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => _openDonate(context),
                  icon: const Icon(Icons.favorite, size: 18),
                  label: const Text('Donate Food'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => setState(() => _tab = 1),
                  icon: const Icon(Icons.shopping_basket_outlined, size: 18),
                  label: const Text('Request Food'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _CategoryChip(
              label: _categories[i],
              selected: _category == _categories[i],
              onTap: () => setState(() => _category = _categories[i]),
            ),
          ),
        ),
        if (_visible.isNotEmpty) ...[
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Nearby Donations',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _visible.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _NearbyDonationCard(
                donation: _visible[i],
                onTap: () => _openDonationDetails(_visible[i]),
              ),
            ),
          ),
        ],
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Available Donations',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _tab = 1),
                child: const Text(
                  'View all',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (_visible.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'No donations match your search.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          )
        else
          ..._visible.map(
            (d) => _DonationCard(d, onTap: () => _openDonationDetails(d)),
          ),
        const SizedBox(height: 16),
      ],
    );
  }
}

OutlineInputBorder _pillBorder(Color color, {double width = 1}) =>
    OutlineInputBorder(
      borderRadius: BorderRadius.circular(30),
      borderSide: BorderSide(color: color, width: width),
    );

/// Green band carrying the greeting and the notification bell.
class _GreetingHeader extends StatelessWidget {
  const _GreetingHeader({
    required this.name,
    required this.notificationRepository,
  });

  final String name;
  final NotificationRepository notificationRepository;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppColors.primary,
      padding: EdgeInsets.fromLTRB(
        20,
        MediaQuery.paddingOf(context).top + 20,
        20,
        96,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, $name!',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Together, we can make\na bigger impact.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: notificationRepository,
            builder: (context, _) {
              final hasUnread = notificationRepository.unreadCount > 0;

              return GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      notificationRepository: notificationRepository,
                    ),
                  ),
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                    if (hasUnread)
                      Positioned(
                        right: 0,
                        top: 1,
                        child: Container(
                          height: 9,
                          width: 9,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// White card straddling the bottom edge of the green header.
class _ImpactCard extends StatelessWidget {
  const _ImpactCard({required this.mealsShared, required this.familiesHelped});
  final String mealsShared;
  final String familiesHelped;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.volunteer_activism,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Our Community Impact',
                  style: TextStyle(
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  height: 1,
                  width: 26,
                  color: AppColors.border,
                ),
                const SizedBox(height: 10),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _ImpactStat(
                          value: mealsShared,
                          label: 'Meals Shared',
                        ),
                      ),
                      const VerticalDivider(
                        width: 16,
                        thickness: 1,
                        color: AppColors.border,
                      ),
                      Expanded(
                        child: _ImpactStat(
                          value: familiesHelped,
                          label: 'Families Helped',
                          icon: Icons.groups,
                        ),
                      ),
                    ],
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

class _ImpactStat extends StatelessWidget {
  const _ImpactStat({required this.value, required this.label, this.icon});
  final String value;
  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: AppColors.accent, size: 20),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Text(
                value,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  height: 1.1,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }
}

/// Compact card for the horizontally scrolling "Nearby Donations" row.
class _NearbyDonationCard extends StatelessWidget {
  const _NearbyDonationCard({required this.donation, required this.onTap});

  final Donation donation;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 88,
              width: double.infinity,
              child: DonationImage(
                imagePath: donation.imagePath,
                borderRadius: 12,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    donation.foodName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.place_outlined,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          donation.pickupAddress,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppColors.textSecondary,
                          ),
                        ),
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

class _DonationCard extends StatelessWidget {
  const _DonationCard(this.donation, {required this.onTap});

  final Donation donation;
  final VoidCallback onTap;

  bool get _isNew =>
      DateTime.now().difference(donation.createdAt) <= const Duration(hours: 24);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        height: 132,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: 118,
              child: DonationImage(
                imagePath: donation.imagePath,
                borderRadius: 12,
              ),
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(left: 10),
                padding: const EdgeInsets.fromLTRB(14, 14, 12, 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            donation.foodName,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_isNew) const _NewBadge(),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _MetaRow(Icons.inventory_2_outlined,
                        'Quantity: ${donation.quantity}'),
                    _MetaRow(Icons.place_outlined,
                        'Pickup: ${donation.pickupAddress}'),
                    _MetaRow(
                      Icons.schedule_outlined,
                      'Use by: ${DateFormat('d MMM yyyy').format(donation.expiryDate)}',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'New',
        style: TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow(this.icon, this.text);
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Five-tab bar: Home, Donations, Requests, Notifications, Profile.
class _BottomBar extends StatelessWidget {
  const _BottomBar({
    required this.current,
    required this.onSelect,
  });

  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: 64 + bottomInset,
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(bottom: bottomInset),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _tab(0, Icons.home, Icons.home_outlined, 'Home'),
                _tab(1, Icons.volunteer_activism, Icons.volunteer_activism_outlined, 'Donations'),
                _tab(2, Icons.assignment, Icons.assignment_outlined, 'Requests'),
                _tab(3, Icons.notifications, Icons.notifications_outlined, 'Notifications'),
                _tab(4, Icons.person, Icons.person_outline, 'Profile'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tab(int index, IconData active, IconData inactive, String label) {
    final selected = current == index;
    final color = selected ? AppColors.primary : AppColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onSelect(index),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? active : inactive, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}
