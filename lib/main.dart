import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/donation.dart';
import 'models/food_request.dart';
import 'providers/auth_provider.dart';
import 'screens/authentication/login_screen.dart';
import 'screens/authentication/register_screen.dart';
import 'screens/authentication/splash_screen.dart';

import 'screens/home_screen.dart';
import 'services/donation_repository.dart';
import 'services/notification_repository.dart';
import 'services/profile_repository.dart';
import 'services/request_repository.dart';
import 'utils/app_routes.dart';
import 'utils/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final donationRepository = DonationRepository();
  final notificationRepository = NotificationRepository();
  final profileRepository = ProfileRepository();

  // Keeps the donation's status in sync whenever a request tied to it
  // changes, as documented in RequestRepository's onDonationStatusChanged.
  final requestRepository = RequestRepository(
    onDonationStatusChanged: (donationId, status) async {
      final matches =
          donationRepository.donations.where((d) => d.id == donationId);
      if (matches.isEmpty) return;
      final donation = matches.first;

      switch (status) {
        case RequestStatus.approved:
          await donationRepository.updateDonation(
            donation.copyWith(status: DonationStatus.reserved),
          );
          break;
        case RequestStatus.rejected:
          await donationRepository.updateDonation(
            donation.copyWith(status: DonationStatus.available),
          );
          break;
        case RequestStatus.completed:
          await donationRepository.markAsCollected(donationId);
          break;
        case RequestStatus.pending:
        case RequestStatus.readyForPickup:
          break;
      }
    },
  );

  await Future.wait([
    donationRepository.load(seedDemoData: true),
    requestRepository.load(seedDemoData: true),
    notificationRepository.load(seedDemoData: true),
    profileRepository.load(seedDemoData: true),
  ]);

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => CommunityCareApp(
        donationRepository: donationRepository,
        requestRepository: requestRepository,
        profileRepository: profileRepository,
        notificationRepository: notificationRepository,
      ),
    ),
  );
}

class CommunityCareApp extends StatelessWidget {
  const CommunityCareApp({
    super.key,
    required this.donationRepository,
    required this.requestRepository,
    required this.profileRepository,
    required this.notificationRepository,
  });

  final DonationRepository donationRepository;
  final RequestRepository requestRepository;
  final ProfileRepository profileRepository;
  final NotificationRepository notificationRepository;

  // Fallback owner id used only if a route is somehow reached while signed
  // out (shouldn't happen — SplashScreen and route guards send signed-out
  // users to /login first).
  static const currentDonorId = 'demo-donor';

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'CommunityCare FoodShare',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        initialRoute: AppRoutes.splash,
        routes: {
          AppRoutes.splash: (_) => const SplashScreen(),
          AppRoutes.login: (_) => const LoginScreen(),
          AppRoutes.register: (_) => const RegisterScreen(),
          AppRoutes.home: (context) {
            // Each signed-in account gets its own donations/requests/profile,
            // so the screens below must key off the real signed-in user
            // instead of the placeholder demo id.
            final userId =
                context.watch<AuthProvider>().user?.id ?? currentDonorId;

            return HomeScreen(
              donationRepository: donationRepository,
              requestRepository: requestRepository,
              profileRepository: profileRepository,
              notificationRepository: notificationRepository,
              currentDonorId: userId,
            );
          },
        },
      ),
    );
  }
}
