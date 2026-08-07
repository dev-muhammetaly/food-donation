import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_routes.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    final auth = context.read<AuthProvider>();
    
    await Future.wait([
      auth.loadSession(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      auth.isLoggedIn ? AppRoutes.home : AppRoutes.login,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 128,
              width: 128,
              decoration: const BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.volunteer_activism,
                size: 68,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'FoodShare',
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
            const Text(
              'Community Care',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Share Food, Support Communities',
              style: TextStyle(fontSize: 15, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 48),
            const SizedBox(
              height: 26,
              width: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
