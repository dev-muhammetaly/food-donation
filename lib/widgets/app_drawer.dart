import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../screens/help_screen.dart';
import '../screens/my_donations_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../services/donation_repository.dart';
import '../services/notification_repository.dart';
import '../services/profile_repository.dart';
import '../services/request_repository.dart';
import '../utils/app_routes.dart';
import '../utils/app_theme.dart';

/// Shared navigation drawer used by the screens that still had a
/// "Menu" button wired to a placeholder message.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.donationRepository,
    required this.requestRepository,
    required this.notificationRepository,
    required this.profileRepository,
    required this.currentUserId,
  });

  final DonationRepository donationRepository;
  final RequestRepository requestRepository;
  final NotificationRepository notificationRepository;
  final ProfileRepository profileRepository;
  final String currentUserId;

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final profile = profileRepository.profile;

    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              color: AppTheme.darkGreen,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.white24,
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    profile?.fullName ?? 'Community Member',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  if (profile != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      profile.email,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            _DrawerItem(
              icon: Icons.home_outlined,
              label: 'Home',
              onTap: () => Navigator.of(context)
                  .popUntil((route) => route.isFirst),
            ),
            _DrawerItem(
              icon: Icons.inventory_2_outlined,
              label: 'My Donations',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyDonationsScreen(
                      donationRepository: donationRepository,
                      notificationRepository: notificationRepository,
                      requestRepository: requestRepository,
                      profileRepository: profileRepository,
                      currentDonorId: currentUserId,
                    ),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.assignment_outlined,
              label: 'My Requests',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => MyRequestsScreen(
                      requestRepository: requestRepository,
                      profileRepository: profileRepository,
                      currentUserId: currentUserId,
                    ),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.notifications_outlined,
              label: 'Notifications',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => NotificationsScreen(
                      notificationRepository: notificationRepository,
                    ),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.person_outline,
              label: 'Profile',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ProfileScreen(
                      profileRepository: profileRepository,
                      onLogout: () => _logout(context),
                    ),
                  ),
                );
              },
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              label: 'About & Help',
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const HelpScreen()),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            _DrawerItem(
              icon: Icons.logout,
              label: 'Logout',
              color: Colors.red,
              onTap: () => _logout(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.darkGreen),
      title: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: onTap,
    );
  }
}
