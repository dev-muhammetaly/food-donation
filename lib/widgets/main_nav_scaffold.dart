import 'package:flutter/material.dart';

import '../services/notification_repository.dart';
import '../services/profile_repository.dart';
import '../screens/notifications_screen.dart';
import '../screens/profile_screen.dart';
import '../utils/app_theme.dart';

/// Member 5's final-integration shell.
///
/// This is the bottom navigation bar described on the Home Page spec:
/// Home, Donations, Requests, Notifications, Profile. It owns the
/// Notifications and Profile tabs directly. The Home, Donations and
/// Requests tabs are integration points — replace [homeTab],
/// [donationsTab] and [requestsTab] with Member 1's, Member 2's and
/// Member 4's real screens once branches are merged.
class MainNavScaffold extends StatefulWidget {
  const MainNavScaffold({
    super.key,
    required this.notificationRepository,
    required this.profileRepository,
    required this.onLogout,
    this.homeTab,
    this.donationsTab,
    this.requestsTab,
  });

  final NotificationRepository notificationRepository;
  final ProfileRepository profileRepository;
  final VoidCallback onLogout;

  final Widget? homeTab;
  final Widget? donationsTab;
  final Widget? requestsTab;

  @override
  State<MainNavScaffold> createState() => _MainNavScaffoldState();
}

class _MainNavScaffoldState extends State<MainNavScaffold> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      widget.homeTab ?? const _PendingModuleTab(label: 'Home — Member 1'),
      widget.donationsTab ??
          const _PendingModuleTab(label: 'Donations — Member 2'),
      widget.requestsTab ??
          const _PendingModuleTab(label: 'Requests — Member 4'),
      NotificationsScreen(
        notificationRepository: widget.notificationRepository,
      ),
      ProfileScreen(
        profileRepository: widget.profileRepository,
        onLogout: widget.onLogout,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: tabs),
      bottomNavigationBar: AnimatedBuilder(
        animation: widget.notificationRepository,
        builder: (context, _) {
          final unread = widget.notificationRepository.unreadCount;

          return NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              const NavigationDestination(
                icon: Icon(Icons.volunteer_activism_outlined),
                selectedIcon: Icon(Icons.volunteer_activism),
                label: 'Donations',
              ),
              const NavigationDestination(
                icon: Icon(Icons.shopping_basket_outlined),
                selectedIcon: Icon(Icons.shopping_basket),
                label: 'Requests',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: unread > 0,
                  label: Text('$unread'),
                  child: const Icon(Icons.notifications_outlined),
                ),
                selectedIcon: const Icon(Icons.notifications),
                label: 'Notifications',
              ),
              const NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          );
        },
      ),
    );
  }
}

class _PendingModuleTab extends StatelessWidget {
  const _PendingModuleTab({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.hourglass_top,
                size: 48,
                color: AppTheme.mediumGreen,
              ),
              const SizedBox(height: 12),
              Text(
                '$label module not merged in yet.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
